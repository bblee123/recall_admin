import 'dart:io';

import 'package:flutter/foundation.dart';

/// PCM 音频的格式描述与波形包络。
///
/// 裁切需要样本级对齐文件，因此这里保留 [dataOffset] / [dataLength]，
/// 让 `AudioTrimmer` 能按帧边界直接切字节，不做重编码。
@immutable
class WaveformData {
  const WaveformData({
    required this.peaks,
    required this.sampleRate,
    required this.numChannels,
    required this.bitsPerSample,
    required this.dataOffset,
    required this.dataLength,
    required this.duration,
    required this.isWav,
    required this.isFloat,
  });

  /// 每桶峰值（0..1），按时间等距排列。
  final Float32List peaks;

  final int sampleRate;
  final int numChannels;
  final int bitsPerSample;

  /// PCM 数据在文件中的起始偏移（裸 PCM 为 0）。
  final int dataOffset;

  /// PCM 数据字节长度。
  final int dataLength;

  final Duration duration;

  /// 源文件是否带 RIFF 头（裸 `.pcm` 为 false）。
  final bool isWav;

  /// 样本是否为 IEEE float（WAVE_FORMAT_IEEE_FLOAT）。
  final bool isFloat;

  /// 单帧字节数（所有声道合计）。
  int get frameSize => numChannels * (bitsPerSample ~/ 8);

  /// 总帧数。
  int get frameCount => frameSize == 0 ? 0 : dataLength ~/ frameSize;

  /// 桶索引 -> 时间。
  Duration timeAt(int index) {
    if (peaks.isEmpty) return Duration.zero;
    final ratio = (index / peaks.length).clamp(0.0, 1.0);
    return Duration(microseconds: (duration.inMicroseconds * ratio).round());
  }

  /// 时间 -> 桶索引。
  int bucketAt(Duration time) {
    if (peaks.isEmpty || duration.inMicroseconds <= 0) return 0;
    final ratio =
        (time.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
    return (ratio * (peaks.length - 1)).round();
  }

  /// 时间 -> 帧对齐后的字节偏移（相对文件起始）。
  int byteOffsetAt(Duration time) {
    if (duration.inMicroseconds <= 0) return dataOffset;
    final ratio =
        (time.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
    final frame = (frameCount * ratio).round().clamp(0, frameCount);
    return dataOffset + frame * frameSize;
  }
}

/// 波形解析异常（格式不支持 / 文件损坏）。
class WaveformException implements Exception {
  const WaveformException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 生成波形包络的参数（需可跨 isolate 传递）。
@immutable
class _EnvelopeRequest {
  const _EnvelopeRequest({
    required this.path,
    required this.bucketsPerSecond,
    required this.maxBuckets,
    required this.fallbackSampleRate,
    required this.fallbackChannels,
    required this.fallbackBits,
  });

  final String path;
  final int bucketsPerSecond;
  final int maxBuckets;

  /// 裸 PCM 无文件头，格式由录音配置提供。
  final int fallbackSampleRate;
  final int fallbackChannels;
  final int fallbackBits;
}

/// WAV / 裸 PCM 的波形包络生成器。
///
/// 只处理未压缩 PCM（含 IEEE float），压缩 WAV 与 FLAC/AAC 不在支持范围内。
class PcmWaveform {
  const PcmWaveform._();

  /// 默认桶密度：每秒 500 个峰值点，足以支撑放大到 ~10ms 精度。
  static const int defaultBucketsPerSecond = 500;

  /// 桶数上限，避免长录音占用过多内存。
  static const int defaultMaxBuckets = 240000;

  /// 在后台 isolate 中解析 [path] 并生成包络。
  ///
  /// [fallbackSampleRate] / [fallbackChannels] 仅对裸 `.pcm` 生效。
  static Future<WaveformData> build(
    String path, {
    required int fallbackSampleRate,
    required int fallbackChannels,
    int fallbackBits = 16,
    int bucketsPerSecond = defaultBucketsPerSecond,
    int maxBuckets = defaultMaxBuckets,
  }) {
    return compute(
      _buildEnvelope,
      _EnvelopeRequest(
        path: path,
        bucketsPerSecond: bucketsPerSecond,
        maxBuckets: maxBuckets,
        fallbackSampleRate: fallbackSampleRate,
        fallbackChannels: fallbackChannels,
        fallbackBits: fallbackBits,
      ),
    );
  }
}

WaveformData _buildEnvelope(_EnvelopeRequest req) {
  final bytes = File(req.path).readAsBytesSync();
  final format = _readFormat(bytes, req);

  final frameSize = format.numChannels * (format.bitsPerSample ~/ 8);
  if (frameSize <= 0) {
    throw const WaveformException('无法识别的音频格式');
  }

  final frameCount = format.dataLength ~/ frameSize;
  if (frameCount <= 0) {
    throw const WaveformException('音频没有可用数据');
  }

  final durationUs =
      (frameCount / format.sampleRate * Duration.microsecondsPerSecond).round();
  final duration = Duration(microseconds: durationUs);

  final wanted =
      (frameCount / format.sampleRate * req.bucketsPerSecond).ceil();
  final bucketCount = wanted.clamp(1, req.maxBuckets);

  final peaks = Float32List(bucketCount);
  final view = ByteData.sublistView(
    bytes,
    format.dataOffset,
    format.dataOffset + format.dataLength,
  );

  // 每桶取绝对值峰值：均值会让有符号样本相互抵消，波形接近直线。
  for (var b = 0; b < bucketCount; b++) {
    final startFrame = (frameCount * b) ~/ bucketCount;
    var endFrame = (frameCount * (b + 1)) ~/ bucketCount;
    if (endFrame <= startFrame) endFrame = startFrame + 1;
    if (endFrame > frameCount) endFrame = frameCount;

    var peak = 0.0;
    for (var f = startFrame; f < endFrame; f++) {
      final base = f * frameSize;
      for (var c = 0; c < format.numChannels; c++) {
        final v = _sampleAt(
          view,
          base + c * (format.bitsPerSample ~/ 8),
          format.bitsPerSample,
          format.isFloat,
        ).abs();
        if (v > peak) peak = v;
      }
    }
    peaks[b] = peak > 1.0 ? 1.0 : peak;
  }

  return WaveformData(
    peaks: peaks,
    sampleRate: format.sampleRate,
    numChannels: format.numChannels,
    bitsPerSample: format.bitsPerSample,
    dataOffset: format.dataOffset,
    dataLength: format.dataLength,
    duration: duration,
    isWav: format.isWav,
    isFloat: format.isFloat,
  );
}

/// 读取单个样本并归一化到 -1..1。
double _sampleAt(ByteData view, int offset, int bits, bool isFloat) {
  switch (bits) {
    case 8:
      // WAV 的 8bit 是无符号，128 为静音中点。
      return (view.getUint8(offset) - 128) / 128.0;
    case 16:
      return view.getInt16(offset, Endian.little) / 32768.0;
    case 24:
      final b0 = view.getUint8(offset);
      final b1 = view.getUint8(offset + 1);
      final b2 = view.getUint8(offset + 2);
      var v = b0 | (b1 << 8) | (b2 << 16);
      if (v & 0x800000 != 0) v -= 0x1000000;
      return v / 8388608.0;
    case 32:
      return isFloat
          ? view.getFloat32(offset, Endian.little)
          : view.getInt32(offset, Endian.little) / 2147483648.0;
    default:
      throw WaveformException('不支持的位深：$bits bit');
  }
}

class _PcmFormat {
  const _PcmFormat({
    required this.sampleRate,
    required this.numChannels,
    required this.bitsPerSample,
    required this.dataOffset,
    required this.dataLength,
    required this.isFloat,
    required this.isWav,
  });

  final int sampleRate;
  final int numChannels;
  final int bitsPerSample;
  final int dataOffset;
  final int dataLength;
  final bool isFloat;
  final bool isWav;
}

/// 解析文件头；不是 RIFF/WAVE 时按裸 PCM 处理。
_PcmFormat _readFormat(Uint8List bytes, _EnvelopeRequest req) {
  if (_hasRiffHeader(bytes)) return _parseWavHeader(bytes);

  return _PcmFormat(
    sampleRate: req.fallbackSampleRate,
    numChannels: req.fallbackChannels,
    bitsPerSample: req.fallbackBits,
    dataOffset: 0,
    dataLength: bytes.length,
    isFloat: false,
    isWav: false,
  );
}

bool _hasRiffHeader(Uint8List bytes) {
  if (bytes.length < 12) return false;
  return bytes[0] == 0x52 && // R
      bytes[1] == 0x49 && // I
      bytes[2] == 0x46 && // F
      bytes[3] == 0x46 && // F
      bytes[8] == 0x57 && // W
      bytes[9] == 0x41 && // A
      bytes[10] == 0x56 && // V
      bytes[11] == 0x45; // E
}

/// 遍历 RIFF chunk，取出 `fmt ` 与 `data`。
///
/// `record` 产出的 WAV 之外还可能夹带 `LIST` / `fact` 等 chunk，
/// 所以不能假设 data 固定在 44 字节处。
_PcmFormat _parseWavHeader(Uint8List bytes) {
  final view = ByteData.sublistView(bytes);

  int? sampleRate;
  int? numChannels;
  int? bitsPerSample;
  var isFloat = false;
  int? dataOffset;
  int? dataLength;

  var pos = 12;
  while (pos + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes, pos, pos + 4);
    final size = view.getUint32(pos + 4, Endian.little);
    final body = pos + 8;

    if (id == 'fmt ') {
      if (body + 16 > bytes.length) {
        throw const WaveformException('WAV 头损坏：fmt 块不完整');
      }
      var audioFormat = view.getUint16(body, Endian.little);
      numChannels = view.getUint16(body + 2, Endian.little);
      sampleRate = view.getUint32(body + 4, Endian.little);
      bitsPerSample = view.getUint16(body + 14, Endian.little);

      // WAVE_FORMAT_EXTENSIBLE：真实格式在 SubFormat 的前两字节。
      if (audioFormat == 0xFFFE && body + 26 <= bytes.length) {
        audioFormat = view.getUint16(body + 24, Endian.little);
      }
      if (audioFormat != 1 && audioFormat != 3) {
        throw const WaveformException('该 WAV 为压缩格式，不支持波形与裁切');
      }
      isFloat = audioFormat == 3;
    } else if (id == 'data') {
      dataOffset = body;
      // 部分写入器会留下未回填的长度，按实际文件长度兜底。
      final available = bytes.length - body;
      dataLength = (size == 0 || size > available) ? available : size;
    }

    if (dataOffset != null && sampleRate != null) break;

    pos = body + size + (size.isOdd ? 1 : 0);
  }

  if (sampleRate == null ||
      numChannels == null ||
      bitsPerSample == null ||
      dataOffset == null ||
      dataLength == null) {
    throw const WaveformException('WAV 头解析失败');
  }

  return _PcmFormat(
    sampleRate: sampleRate,
    numChannels: numChannels,
    bitsPerSample: bitsPerSample,
    dataOffset: dataOffset,
    dataLength: dataLength,
    isFloat: isFloat,
    isWav: true,
  );
}

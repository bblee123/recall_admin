import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'pcm_waveform.dart';

/// 按时间区间裁切 PCM 音频，直接切字节、不重编码。
///
/// 仅支持 WAV 与裸 PCM（见 `RecorderCodec.supportsTrim`）；
/// FLAC / AAC 需要重新编码，不在支持范围内。
class AudioTrimmer {
  const AudioTrimmer._();

  /// 最短保留时长，避免拖成 0 长度文件。
  static const Duration minDuration = Duration(milliseconds: 30);

  /// 把 [sourcePath] 的 [start] ~ [end] 区间写成新文件，返回新文件路径。
  ///
  /// [waveform] 提供格式与 PCM 数据位置，由 [PcmWaveform.build] 得到。
  static Future<String> trim({
    required String sourcePath,
    required WaveformData waveform,
    required Duration start,
    required Duration end,
  }) async {
    if (end - start < minDuration) {
      throw const WaveformException('裁切区间过短');
    }

    final source = File(sourcePath);
    final bytes = await source.readAsBytes();

    final frameSize = waveform.frameSize;
    if (frameSize <= 0) {
      throw const WaveformException('无法识别的音频格式');
    }

    // 对齐到帧边界，否则会把某一声道的样本切成两半产生爆音。
    var from = waveform.byteOffsetAt(start);
    var to = waveform.byteOffsetAt(end);
    from -= (from - waveform.dataOffset) % frameSize;
    to -= (to - waveform.dataOffset) % frameSize;

    final dataEnd = waveform.dataOffset + waveform.dataLength;
    from = from.clamp(waveform.dataOffset, dataEnd);
    to = to.clamp(from + frameSize, dataEnd);

    final pcm = Uint8List.sublistView(bytes, from, to);
    final target = _targetPath(sourcePath);

    final output = waveform.isWav
        ? _wrapAsWav(
            pcm,
            sampleRate: waveform.sampleRate,
            numChannels: waveform.numChannels,
            bitsPerSample: waveform.bitsPerSample,
            isFloat: waveform.isFloat,
          )
        : pcm;

    final file = File(target);
    await file.writeAsBytes(output, flush: true);
    return file.path;
  }

  /// 与源文件同目录、同扩展名的临时裁切产物。
  static String _targetPath(String sourcePath) {
    final dir = p.dirname(sourcePath);
    final stem = p.basenameWithoutExtension(sourcePath);
    final ext = p.extension(sourcePath);
    final ts = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir, '${stem}_trim_$ts$ext');
  }

  /// 给裁切后的 PCM 套上标准 44 字节 RIFF 头。
  static Uint8List _wrapAsWav(
    Uint8List pcm, {
    required int sampleRate,
    required int numChannels,
    required int bitsPerSample,
    required bool isFloat,
  }) {
    const headerSize = 44;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);

    final out = Uint8List(headerSize + pcm.length);
    final view = ByteData.sublistView(out);

    void writeTag(int offset, String tag) {
      for (var i = 0; i < 4; i++) {
        out[offset + i] = tag.codeUnitAt(i);
      }
    }

    writeTag(0, 'RIFF');
    view.setUint32(4, headerSize - 8 + pcm.length, Endian.little);
    writeTag(8, 'WAVE');

    writeTag(12, 'fmt ');
    view.setUint32(16, 16, Endian.little);
    view.setUint16(20, isFloat ? 3 : 1, Endian.little);
    view.setUint16(22, numChannels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(28, byteRate, Endian.little);
    view.setUint16(32, blockAlign, Endian.little);
    view.setUint16(34, bitsPerSample, Endian.little);

    writeTag(36, 'data');
    view.setUint32(40, pcm.length, Endian.little);
    out.setRange(headerSize, headerSize + pcm.length, pcm);

    return out;
  }
}

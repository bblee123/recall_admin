import 'package:record/record.dart';

/// 采样率档位（Hz）。实际生效值取决于硬件，若不支持会由
/// [AudioRecorder.setOnConfigChanged] 回报真实值。
enum SampleRateTier {
  rate16k(16000, '16 kHz · 语音'),
  rate22k(22050, '22.05 kHz'),
  rate44k(44100, '44.1 kHz · CD'),
  rate48k(48000, '48 kHz · 录音棚'),
  rate96k(96000, '96 kHz · 高解析(需设备支持)');

  const SampleRateTier(this.hz, this.label);

  final int hz;
  final String label;

  static SampleRateTier fromHz(int hz) {
    for (final t in SampleRateTier.values) {
      if (t.hz == hz) return t;
    }
    return SampleRateTier.rate48k;
  }
}

/// macOS 支持的编码器子集，附带默认扩展名。
enum RecorderCodec {
  wav(AudioEncoder.wav, 'wav', 'WAV · 无损'),
  pcm16(AudioEncoder.pcm16bits, 'pcm', 'PCM 16bit · 裸流'),
  flac(AudioEncoder.flac, 'flac', 'FLAC · 无损压缩'),
  aacLc(AudioEncoder.aacLc, 'm4a', 'AAC-LC · 有损');

  const RecorderCodec(this.encoder, this.fileExtension, this.label);

  final AudioEncoder encoder;
  final String fileExtension;
  final String label;

  /// 是否为有损编码器（有损才需要 bitRate）。
  bool get isLossy => this == RecorderCodec.aacLc;
}

/// 录音配置（不可变）。默认追求清晰度：WAV / 48kHz / 单声道。
class RecorderOptions {
  const RecorderOptions({
    this.sampleRate = SampleRateTier.rate48k,
    this.codec = RecorderCodec.wav,
    this.numChannels = 1,
    this.bitRate = 256000,
    this.deviceId,
    this.deviceLabel,
    this.autoGain = false,
    this.echoCancel = false,
    this.noiseSuppress = false,
    this.outputDir,
    this.fileNamePrefix = 'rec',
  });

  final SampleRateTier sampleRate;
  final RecorderCodec codec;

  /// 声道数：单词录音默认 1（单声道），也可 2。
  final int numChannels;

  /// 有损编码码率（bps），仅 [RecorderCodec.isLossy] 时生效。
  final int bitRate;

  /// 选中的输入设备 id（null 表示系统默认设备）。
  final String? deviceId;
  final String? deviceLabel;

  final bool autoGain;
  final bool echoCancel;
  final bool noiseSuppress;

  /// 录音保存目录（null 表示使用系统临时/文档目录）。
  final String? outputDir;

  /// 文件名前缀，最终文件名形如 `<prefix>_<timestamp>.<ext>`。
  final String fileNamePrefix;

  RecorderOptions copyWith({
    SampleRateTier? sampleRate,
    RecorderCodec? codec,
    int? numChannels,
    int? bitRate,
    String? deviceId,
    String? deviceLabel,
    bool? clearDevice,
    bool? autoGain,
    bool? echoCancel,
    bool? noiseSuppress,
    String? outputDir,
    String? fileNamePrefix,
  }) {
    final removeDevice = clearDevice ?? false;
    return RecorderOptions(
      sampleRate: sampleRate ?? this.sampleRate,
      codec: codec ?? this.codec,
      numChannels: numChannels ?? this.numChannels,
      bitRate: bitRate ?? this.bitRate,
      deviceId: removeDevice ? null : (deviceId ?? this.deviceId),
      deviceLabel: removeDevice ? null : (deviceLabel ?? this.deviceLabel),
      autoGain: autoGain ?? this.autoGain,
      echoCancel: echoCancel ?? this.echoCancel,
      noiseSuppress: noiseSuppress ?? this.noiseSuppress,
      outputDir: outputDir ?? this.outputDir,
      fileNamePrefix: fileNamePrefix ?? this.fileNamePrefix,
    );
  }
}

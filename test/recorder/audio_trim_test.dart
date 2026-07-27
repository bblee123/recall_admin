import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:recall_admin/features/recorder/service/audio_trimmer.dart';
import 'package:recall_admin/features/recorder/service/pcm_waveform.dart';

/// 生成一段 16bit 单声道 WAV：前 1s 静音，中间 1s 满幅正弦，后 1s 静音。
Uint8List buildTestWav({
  int sampleRate = 8000,
  int numChannels = 1,
  bool withExtraChunk = false,
}) {
  const totalSeconds = 3;
  final frames = sampleRate * totalSeconds;
  final pcm = Uint8List(frames * numChannels * 2);
  final pcmView = ByteData.sublistView(pcm);

  for (var f = 0; f < frames; f++) {
    final t = f / sampleRate;
    final loud = t >= 1.0 && t < 2.0;
    final value = loud ? (math.sin(2 * math.pi * 440 * t) * 32000).round() : 0;
    for (var c = 0; c < numChannels; c++) {
      pcmView.setInt16((f * numChannels + c) * 2, value, Endian.little);
    }
  }

  // 可选插入一个 LIST chunk，验证解析器不假设 data 固定在 44 字节处。
  final extra = withExtraChunk ? 8 + 10 : 0;
  final out = Uint8List(44 + extra + pcm.length);
  final view = ByteData.sublistView(out);

  void tag(int offset, String s) {
    for (var i = 0; i < 4; i++) {
      out[offset + i] = s.codeUnitAt(i);
    }
  }

  tag(0, 'RIFF');
  view.setUint32(4, out.length - 8, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  view.setUint32(16, 16, Endian.little);
  view.setUint16(20, 1, Endian.little);
  view.setUint16(22, numChannels, Endian.little);
  view.setUint32(24, sampleRate, Endian.little);
  view.setUint32(28, sampleRate * numChannels * 2, Endian.little);
  view.setUint16(32, numChannels * 2, Endian.little);
  view.setUint16(34, 16, Endian.little);

  var pos = 36;
  if (withExtraChunk) {
    tag(pos, 'LIST');
    view.setUint32(pos + 4, 10, Endian.little);
    pos += 18;
  }

  tag(pos, 'data');
  view.setUint32(pos + 4, pcm.length, Endian.little);
  out.setRange(pos + 8, pos + 8 + pcm.length, pcm);
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('recorder_trim_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<String> writeWav(Uint8List bytes, [String name = 'src.wav']) async {
    final file = File('${tmp.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  group('PcmWaveform', () {
    test('解析 WAV 头并生成与内容相符的包络', () async {
      final path = await writeWav(buildTestWav());
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );

      expect(wf.isWav, isTrue);
      expect(wf.sampleRate, 8000);
      expect(wf.numChannels, 1);
      expect(wf.bitsPerSample, 16);
      expect(wf.duration.inMilliseconds, closeTo(3000, 5));

      // 前后 1s 静音、中间 1s 有声。
      final n = wf.peaks.length;
      expect(wf.peaks[n ~/ 6], lessThan(0.01));
      expect(wf.peaks[n ~/ 2], greaterThan(0.9));
      expect(wf.peaks[n * 5 ~/ 6], lessThan(0.01));
    });

    test('data 块不在固定偏移时仍能解析', () async {
      final path = await writeWav(buildTestWav(withExtraChunk: true));
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );

      expect(wf.dataOffset, 62);
      expect(wf.duration.inMilliseconds, closeTo(3000, 5));
      expect(wf.peaks[wf.peaks.length ~/ 2], greaterThan(0.9));
    });

    test('立体声按帧计算时长', () async {
      final path = await writeWav(buildTestWav(numChannels: 2));
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 2,
      );

      expect(wf.numChannels, 2);
      expect(wf.frameSize, 4);
      expect(wf.duration.inMilliseconds, closeTo(3000, 5));
    });
  });

  group('AudioTrimmer', () {
    test('裁掉首尾静音后只剩有声段', () async {
      final path = await writeWav(buildTestWav());
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );

      final trimmed = await AudioTrimmer.trim(
        sourcePath: path,
        waveform: wf,
        start: const Duration(seconds: 1),
        end: const Duration(seconds: 2),
      );

      final result = await PcmWaveform.build(
        trimmed,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );

      expect(result.isWav, isTrue);
      expect(result.sampleRate, 8000);
      expect(result.numChannels, 1);
      expect(result.duration.inMilliseconds, closeTo(1000, 5));
      // 整段都应是有声内容。
      expect(result.peaks.first, greaterThan(0.5));
      expect(result.peaks.last, greaterThan(0.5));
    });

    test('裁切结果字节长度按帧对齐', () async {
      final path = await writeWav(buildTestWav(numChannels: 2));
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 2,
      );

      final trimmed = await AudioTrimmer.trim(
        sourcePath: path,
        waveform: wf,
        start: const Duration(milliseconds: 333),
        end: const Duration(milliseconds: 1777),
      );

      final bytes = await File(trimmed).readAsBytes();
      expect((bytes.length - 44) % wf.frameSize, 0);
    });

    test('区间过短时拒绝裁切', () async {
      final path = await writeWav(buildTestWav());
      final wf = await PcmWaveform.build(
        path,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );

      expect(
        () => AudioTrimmer.trim(
          sourcePath: path,
          waveform: wf,
          start: const Duration(milliseconds: 1000),
          end: const Duration(milliseconds: 1010),
        ),
        throwsA(isA<WaveformException>()),
      );
    });

    test('裸 PCM 无头时按录音配置解析并直接切片', () async {
      final full = buildTestWav();
      final raw = Uint8List.sublistView(full, 44);
      final file = File('${tmp.path}/src.pcm');
      await file.writeAsBytes(raw);

      final wf = await PcmWaveform.build(
        file.path,
        fallbackSampleRate: 8000,
        fallbackChannels: 1,
      );
      expect(wf.isWav, isFalse);
      expect(wf.duration.inMilliseconds, closeTo(3000, 5));

      final trimmed = await AudioTrimmer.trim(
        sourcePath: file.path,
        waveform: wf,
        start: const Duration(seconds: 1),
        end: const Duration(seconds: 2),
      );

      final bytes = await File(trimmed).readAsBytes();
      // 裸 PCM 不加头：1s * 8000Hz * 2 字节。
      expect(bytes.length, 16000);
    });
  });
}

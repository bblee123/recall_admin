import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'recorder_dialog.dart';
import 'service/recorder_options.dart';

/// 录音测试页：用于在菜单中快速验证 Recorder Modal。
class RecorderTestPage extends StatefulWidget {
  const RecorderTestPage({super.key});

  @override
  State<RecorderTestPage> createState() => _RecorderTestPageState();
}

class _RecorderTestPageState extends State<RecorderTestPage> {
  String? _lastSavedPath;

  Future<void> _openRecorder() async {
    final path = await showRecorderDialog(
      context,
      suggestName: 'word_demo',
      defaults: const RecorderOptions(
        sampleRate: SampleRateTier.rate48k,
        codec: RecorderCodec.wav,
        numChannels: 1,
      ),
    );

    if (!mounted) return;
    if (path == null) {
      showToast('已取消录音');
      return;
    }
    setState(() => _lastSavedPath = path);
    showToast('录音已保存');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '录音测试',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '用于验证 showRecorderDialog：空格开始/结束、波形、设备选择、保存路径。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openRecorder,
              icon: const Icon(Icons.mic),
              label: const Text('打开录音弹窗'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('最近保存路径：'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastSavedPath ?? '暂无',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

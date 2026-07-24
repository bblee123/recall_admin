import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/recorder_cubit.dart';
import 'service/audio_recorder_service.dart';
import 'service/recorder_options.dart';
import 'service/recorder_player_service.dart';
import 'service/recorder_sink.dart';
import 'widgets/recorder_panel.dart';
import 'widgets/recorder_settings.dart';

/// 以 Modal 弹窗打开录音界面，返回保存后的文件路径（取消则为 null）。
///
/// 用法（在列表 row 的 onTap 中）：
/// ```dart
/// final path = await showRecorderDialog(context, suggestName: word.text);
/// ```
Future<String?> showRecorderDialog(
  BuildContext context, {
  String? suggestName,
  RecorderOptions? defaults,
}) {
  final service = context.read<AudioRecorderService>();
  final player = _readPlayerOrNull(context);
  final sink = _readSinkOrNull(context);
  final options = (defaults ?? const RecorderOptions()).copyWith(
    fileNamePrefix: (suggestName == null || suggestName.isEmpty)
        ? null
        : _sanitize(suggestName),
  );

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider<RecorderCubit>(
      create: (_) => RecorderCubit(
        service: service,
        sink: sink,
        player: player,
        initialOptions: options,
      )..init(),
      child: RecorderDialog(
        title: suggestName == null ? '录音' : '录音 · $suggestName',
        preferredName: suggestName,
      ),
    ),
  );
}

RecorderSink? _readSinkOrNull(BuildContext context) {
  try {
    return context.read<RecorderSink>();
  } catch (_) {
    return null;
  }
}

RecorderPlayerService? _readPlayerOrNull(BuildContext context) {
  try {
    return context.read<RecorderPlayerService>();
  } catch (_) {
    return null;
  }
}

String _sanitize(String name) =>
    name.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');

/// 录音弹窗内容（设置区可折叠 + 录音面板）。
class RecorderDialog extends StatefulWidget {
  const RecorderDialog({
    super.key,
    required this.title,
    this.preferredName,
  });

  final String title;
  final String? preferredName;

  @override
  State<RecorderDialog> createState() => _RecorderDialogState();
}

class _RecorderDialogState extends State<RecorderDialog> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: '录音设置',
                    icon: Icon(_showSettings
                        ? Icons.tune
                        : Icons.tune_outlined),
                    isSelected: _showSettings,
                    onPressed: () =>
                        setState(() => _showSettings = !_showSettings),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: RecorderSettings(),
                ),
                crossFadeState: _showSettings
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
              RecorderPanel(
                preferredName: widget.preferredName,
                onSaved: (path) => Navigator.of(context).pop(path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';
import '../cubit/recorder_state.dart';
import 'waveform_view.dart';

/// 可复用录音面板（纯 UI，仅读写注入的 [RecorderCubit]）。
///
/// 布局：左上角时长；左侧开始/结束切换按钮；右侧波形；底部重置与保存。
/// 支持空格键：开始 / 结束 来回切换。
class RecorderPanel extends StatefulWidget {
  const RecorderPanel({
    super.key,
    this.onSaved,
    this.preferredName,
    this.autofocus = true,
  });

  /// 保存成功回调（返回最终路径）。
  final ValueChanged<String>? onSaved;

  /// 保存时的期望文件名（不含扩展名）。
  final String? preferredName;

  /// 是否自动聚焦以接收空格键。
  final bool autofocus;

  @override
  State<RecorderPanel> createState() => _RecorderPanelState();
}

class _RecorderPanelState extends State<RecorderPanel> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'recorder_panel');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      context.read<RecorderCubit>().toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$m:$s.$ms';
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<RecorderCubit>();
    final path = await cubit.save(preferredName: widget.preferredName);
    if (path != null) widget.onSaved?.call(path);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.opaque,
        child: BlocBuilder<RecorderCubit, RecorderState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, state),
                const SizedBox(height: 12),
                _body(context, state),
                if (state.hasPreview) ...[
                  const SizedBox(height: 12),
                  _preview(context, state),
                ],
                const SizedBox(height: 16),
                _footer(context, state),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  Text(state.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, RecorderState state) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          state.isRecording ? Icons.fiber_manual_record : Icons.timer_outlined,
          size: 18,
          color: state.isRecording ? Colors.red : theme.colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          _fmt(state.elapsed),
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          _statusText(state),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  String _statusText(RecorderState state) {
    switch (state.status) {
      case RecorderStatus.idle:
        return '按空格开始';
      case RecorderStatus.recording:
        return '录音中 · 按空格结束';
      case RecorderStatus.stopped:
        return '已停止 · 可保存';
      case RecorderStatus.saved:
        return '已保存';
    }
  }

  Widget _body(BuildContext context, RecorderState state) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          _toggleButton(context, state),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: WaveformView(
                amplitudes: state.amplitudes,
                active: state.isRecording,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(BuildContext context, RecorderState state) {
    final recording = state.isRecording;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 100,
      height: 100,
      child: Material(
        color: recording ? scheme.errorContainer : scheme.primaryContainer,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.read<RecorderCubit>().toggle(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 36,
                color: recording
                    ? scheme.onErrorContainer
                    : scheme.onPrimaryContainer,
              ),
              const SizedBox(height: 4),
              Text(
                recording ? '结束' : '开始',
                style: TextStyle(
                  color: recording
                      ? scheme.onErrorContainer
                      : scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, RecorderState state) {
    final cubit = context.read<RecorderCubit>();
    final scheme = Theme.of(context).colorScheme;
    final total = state.playbackDuration;
    final pos = state.playbackPosition;
    final progress = total.inMilliseconds > 0
        ? (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final playing = state.isPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: playing ? '暂停' : '播放',
            icon: Icon(playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill),
            iconSize: 34,
            color: scheme.primary,
            onPressed: () =>
                playing ? cubit.pausePreview() : cubit.playPreview(),
          ),
          IconButton(
            tooltip: '停止',
            icon: const Icon(Icons.stop_circle_outlined),
            iconSize: 30,
            onPressed: (state.isPlaying || state.isPaused)
                ? () => cubit.stopPreview()
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: scheme.outlineVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  '试听（未保存）  ${_fmt(pos)} / ${_fmt(total)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, RecorderState state) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: state.canReset
              ? () => context.read<RecorderCubit>().reset()
              : null,
          icon: const Icon(Icons.restart_alt),
          label: const Text('重置'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: state.canSave ? () => _save(context) : null,
          icon: state.busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('保存'),
        ),
      ],
    );
  }
}

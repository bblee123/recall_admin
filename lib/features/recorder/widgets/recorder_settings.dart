import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';
import '../cubit/recorder_state.dart';
import '../service/recorder_options.dart';

/// 录音配置区：采样率档位、编码器、输入设备、输出目录、降噪等。
/// 录音进行中时整体禁用，避免中途改配置。
class RecorderSettings extends StatelessWidget {
  const RecorderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecorderCubit, RecorderState>(
      builder: (context, state) {
        final cubit = context.read<RecorderCubit>();
        final opts = state.options;
        final disabled = state.isRecording;

        return AbsorbPointer(
          absorbing: disabled,
          child: Opacity(
            opacity: disabled ? 0.5 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _dropdown<SampleRateTier>(
                        label: '采样率',
                        value: opts.sampleRate,
                        items: SampleRateTier.values
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.label)))
                            .toList(),
                        onChanged: (v) => cubit.updateOptions(
                            opts.copyWith(sampleRate: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown<RecorderCodec>(
                        label: '编码格式',
                        value: opts.codec,
                        items: RecorderCodec.values
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c.label)))
                            .toList(),
                        onChanged: (v) =>
                            cubit.updateOptions(opts.copyWith(codec: v)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _dropdown<int>(
                        label: '声道',
                        value: opts.numChannels,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('单声道')),
                          DropdownMenuItem(value: 2, child: Text('立体声')),
                        ],
                        onChanged: (v) => cubit.updateOptions(
                            opts.copyWith(numChannels: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _deviceDropdown(context, state, cubit),
                    ),
                  ],
                ),
                if (state.effectiveSampleRate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '实际采样率：${state.effectiveSampleRate} Hz',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.teal),
                  ),
                ],
                const SizedBox(height: 12),
                _outputDir(context, state, cubit),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  children: [
                    _switch(
                      label: '自动增益',
                      value: opts.autoGain,
                      onChanged: (v) =>
                          cubit.updateOptions(opts.copyWith(autoGain: v)),
                    ),
                    _switch(
                      label: '回声消除',
                      value: opts.echoCancel,
                      onChanged: (v) =>
                          cubit.updateOptions(opts.copyWith(echoCancel: v)),
                    ),
                    _switch(
                      label: '降噪',
                      value: opts.noiseSuppress,
                      onChanged: (v) => cubit
                          .updateOptions(opts.copyWith(noiseSuppress: v)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _deviceDropdown(
    BuildContext context,
    RecorderState state,
    RecorderCubit cubit,
  ) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(value: null, child: Text('系统默认设备')),
      ...state.devices.map(
        (d) => DropdownMenuItem(value: d.id, child: Text(d.label)),
      ),
    ];
    // 若当前选中的设备已不在列表（拔出），回退到默认。
    final current =
        state.devices.any((d) => d.id == state.options.deviceId)
            ? state.options.deviceId
            : null;
    return Row(
      children: [
        Expanded(
          child: _dropdown<String?>(
            label: '输入设备',
            value: current,
            items: items,
            onChanged: (v) {
              if (v == null) {
                cubit.updateOptions(state.options.copyWith(clearDevice: true));
              } else {
                final dev = state.devices.firstWhere((d) => d.id == v);
                cubit.updateOptions(state.options
                    .copyWith(deviceId: dev.id, deviceLabel: dev.label));
              }
            },
          ),
        ),
        IconButton(
          tooltip: '刷新设备',
          icon: const Icon(Icons.refresh),
          onPressed: () => cubit.refreshDevices(),
        ),
      ],
    );
  }

  Widget _outputDir(
    BuildContext context,
    RecorderState state,
    RecorderCubit cubit,
  ) {
    final dir = state.options.outputDir;
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '保存目录',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: Text(
              dir == null || dir.isEmpty ? '默认（文档/recordings）' : dir,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.folder_open),
          label: const Text('选择'),
          onPressed: () async {
            final picked = await FilePicker.getDirectoryPath();
            if (picked != null) {
              cubit.updateOptions(state.options.copyWith(outputDir: picked));
            }
          },
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _switch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}

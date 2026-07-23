import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recall_admin/utils/responsive.dart';

import '../../core/audio/myenc_audio_service.dart';
import '../../core/env.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/variant.dart';
import '../../data/repositories/variant_repository.dart';
import '../common/file_pick.dart';
import '../common/paginator.dart';
import 'variant_cubit.dart';
import 'variant_state.dart';
import 'widgets/variant_edit_dialog.dart';

/// 汉字释义管理页（对照 variant/index.vue）。
class VariantPage extends StatelessWidget {
  const VariantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VariantCubit>(
      create: (context) =>
          VariantCubit(context.read<VariantRepository>())..load(),
      child: const _VariantView(),
    );
  }
}

class _VariantView extends StatefulWidget {
  const _VariantView();

  @override
  State<_VariantView> createState() => _VariantViewState();
}

class _VariantViewState extends State<_VariantView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _play(Variant v) async {
    final url =
        '${Env.apiBaseUrl}/media/audios/${v.charText}_${v.pinyinRaw}.myenc';
    try {
      await context.read<MyencAudioService>().playEncryptedUrl(url);
    } catch (e) {
      showToast('播放失败：$e');
    }
  }

  Future<void> _upload(Variant v) async {
    final cubit = context.read<VariantCubit>();
    final file = await pickSingleFile(
      type: FileType.custom,
      allowedExtensions: const <String>['mp3', 'ogg', 'wav', 'm4a'],
    );
    if (file == null) return;
    try {
      await cubit.uploadAudio(v, file);
      showToast('上传成功');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  Future<void> _delete(Variant v) async {
    final cubit = context.read<VariantCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确定要删除这个音频吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await cubit.deleteAudio(v);
      showToast('删除成功');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  Future<void> _generate(Variant v) async {
    final cubit = context.read<VariantCubit>();
    try {
      await cubit.generateAudio(v);
      await cubit.load();
      showToast('${v.charText}_${v.pinyinRaw} 生成成功');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  Future<void> _batch() async {
    final cubit = context.read<VariantCubit>();
    if (cubit.state.selectedIds.isEmpty) {
      showToast('请选择要生成音频的字符');
      return;
    }
    showToast('开始批量生成…');
    try {
      await cubit.batchGenerate();
      showToast('批量生成完成');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  Future<void> _edit({Variant? initial}) async {
    final cubit = context.read<VariantCubit>();
    await showVariantEditDialog(
      context,
      initial: initial,
      onSave: cubit.saveVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<VariantCubit, VariantState>(
          builder: (context, state) {
            final cubit = context.read<VariantCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flex(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  direction: context.responsive(
                    sm: Axis.vertical,
                    lg: Axis.horizontal,
                  ),
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 1, label: Text('全部')),
                            ButtonSegment(value: 2, label: Text('已生成')),
                            ButtonSegment(value: 3, label: Text('未生成')),
                          ],
                          selected: {state.audioType},
                          onSelectionChanged: (s) =>
                              cubit.setAudioType(s.first),
                        ),
                        SizedBox(
                          width: 240,
                          child: TextField(
                            controller: _search,
                            decoration: const InputDecoration(
                              hintText: '请输入汉字 or 拼音',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: cubit.setSearch,
                            onSubmitted: (_) => cubit.searchNow(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          onPressed: cubit.searchNow,
                          child: const Text('搜索'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _edit(),
                          child: const Text('创建'),
                        ),
                        FilledButton.tonal(
                          onPressed: _batch,
                          child: const Text('AI Audios'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '错误：${state.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : _VariantTable(
                          state: state,
                          onSelect: cubit.toggleSelect,
                          onPlay: _play,
                          onUpload: _upload,
                          onDelete: _delete,
                          onGenerate: _generate,
                          onEdit: (v) => _edit(initial: v),
                        ),
                ),
                Paginator(
                  page: state.page,
                  pageSize: state.pageSize,
                  total: state.total,
                  pageSizeOptions: const [20, 50, 100, 200],
                  onPageChanged: cubit.setPage,
                  onPageSizeChanged: cubit.setPageSize,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VariantTable extends StatelessWidget {
  const _VariantTable({
    required this.state,
    required this.onSelect,
    required this.onPlay,
    required this.onUpload,
    required this.onDelete,
    required this.onGenerate,
    required this.onEdit,
  });

  final VariantState state;
  final void Function(int id, bool selected) onSelect;
  final ValueChanged<Variant> onPlay;
  final ValueChanged<Variant> onUpload;
  final ValueChanged<Variant> onDelete;
  final ValueChanged<Variant> onGenerate;
  final ValueChanged<Variant> onEdit;

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      minWidth: 1600,
      columns: const [
        DataColumn2(fixedWidth: 50, label: Text('选择')),
        DataColumn2(fixedWidth: 50, label: Text('No.')),
        DataColumn2(fixedWidth: 240, label: Text('音频')),
        DataColumn2(fixedWidth: 100, label: Text('汉字')),
        DataColumn2(fixedWidth: 100, label: Text('拼音')),
        DataColumn2(label: Text('释义')),
        DataColumn2(label: Text('例句')),
        DataColumn2(fixedWidth: 120, label: Text('原始拼音')),
        DataColumn2(fixedWidth: 80, label: Text('操作')),
      ],
      rows: [
        for (var i = 0; i < state.items.length; i++)
          _buildRow(state.items[i], (state.page - 1) * state.pageSize + i + 1),
      ],
    );
  }

  DataRow _buildRow(Variant v, int index) {
    return DataRow(
      cells: [
        DataCell(
          Checkbox(
            value: state.selectedIds.contains(v.id),
            onChanged: (val) => onSelect(v.id, val ?? false),
          ),
        ),
        DataCell(Text('$index')),
        DataCell(
          _AudioCell(
            variant: v,
            onPlay: onPlay,
            onUpload: onUpload,
            onDelete: onDelete,
            onGenerate: onGenerate,
          ),
        ),
        DataCell(Text(v.charText)),
        DataCell(Text(v.pinyin)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              v.meaning,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              v.samples ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        DataCell(Text(v.pinyinRaw)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => onEdit(v),
          ),
        ),
      ],
    );
  }
}

class _AudioCell extends StatelessWidget {
  const _AudioCell({
    required this.variant,
    required this.onPlay,
    required this.onUpload,
    required this.onDelete,
    required this.onGenerate,
  });

  final Variant variant;
  final ValueChanged<Variant> onPlay;
  final ValueChanged<Variant> onUpload;
  final ValueChanged<Variant> onDelete;
  final ValueChanged<Variant> onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (variant.hasAudio) ...[
          IconButton(
            tooltip: '播放',
            icon: const Icon(Icons.play_circle, color: Colors.green, size: 20),
            onPressed: () => onPlay(variant),
          ),
          IconButton(
            tooltip: '重新上传',
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => onUpload(variant),
          ),
          IconButton(
            tooltip: '删除音频',
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            onPressed: () => onDelete(variant),
          ),
        ] else
          IconButton(
            tooltip: '上传音频',
            icon: const Icon(Icons.upload_file, size: 18),
            onPressed: () => onUpload(variant),
          ),
        IconButton(
          tooltip: 'AI 生成',
          icon: const Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
          onPressed: () => onGenerate(variant),
        ),
      ],
    );
  }
}

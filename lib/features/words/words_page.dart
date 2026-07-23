import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/word.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../common/paginator.dart';
import 'widgets/word_edit_dialog.dart';
import 'word_cubit.dart';
import 'word_state.dart';

/// 词汇管理页（对照 words/index.vue）。
class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WordCubit>(
      create: (context) => WordCubit(context.read<WordRepository>())..load(),
      child: const _WordsView(),
    );
  }
}

class _WordsView extends StatefulWidget {
  const _WordsView();

  @override
  State<_WordsView> createState() => _WordsViewState();
}

class _WordsViewState extends State<_WordsView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _edit({Word? initial}) async {
    final cubit = context.read<WordCubit>();
    final charRepo = context.read<CharacterRepository>();
    await showWordEditDialog(
      context,
      initial: initial,
      characterRepository: charRepo,
      onSave: cubit.saveWord,
    );
  }

  Future<void> _delete(Word w) async {
    final cubit = context.read<WordCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('你确定要删除这个单词吗?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true || w.id == null) return;
    try {
      await cubit.deleteWord(w.id!);
      showToast('删除成功');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<WordCubit, WordState>(
          builder: (context, state) {
            final cubit = context.read<WordCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('精确')),
                        ButtonSegment(value: 0, label: Text('模糊')),
                      ],
                      selected: {state.searchType},
                      onSelectionChanged: (s) => cubit.setSearchType(s.first),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          hintText: '请输入词汇',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: cubit.setSearch,
                        onSubmitted: (_) => cubit.searchNow(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: cubit.searchNow, child: const Text('搜索')),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () => _edit(),
                      child: const Text('创建'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('错误：${state.error}',
                        style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : _WordTable(
                          items: state.items,
                          onEdit: (w) => _edit(initial: w),
                          onDelete: _delete,
                        ),
                ),
                Paginator(
                  page: state.page,
                  pageSize: state.pageSize,
                  total: state.total,
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

class _WordTable extends StatelessWidget {
  const _WordTable({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Word> items;
  final ValueChanged<Word> onEdit;
  final ValueChanged<Word> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('词汇')),
            DataColumn(label: Text('拼音')),
            DataColumn(label: Text('原始拼音')),
            DataColumn(label: Text('释义')),
            DataColumn(label: Text('多音字')),
            DataColumn(label: Text('操作')),
          ],
          rows: [
            for (var i = 0; i < items.length; i++)
              DataRow(cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(items[i].text)),
                DataCell(Text(items[i].pinyin ?? '')),
                DataCell(Text(items[i].pinyinRaw ?? '')),
                DataCell(ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(items[i].translation ?? '',
                      overflow: TextOverflow.ellipsis, maxLines: 2),
                )),
                DataCell(items[i].isPolyphone
                    ? const Chip(
                        label: Text('是'),
                        backgroundColor: Color(0xFFD7F5DD),
                        visualDensity: VisualDensity.compact,
                      )
                    : const Chip(
                        label: Text('否'),
                        visualDensity: VisualDensity.compact,
                      )),
                DataCell(Row(
                  children: [
                    TextButton(
                        onPressed: () => onEdit(items[i]),
                        child: const Text('修改')),
                    TextButton(
                      onPressed: () => onDelete(items[i]),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('删除'),
                    ),
                  ],
                )),
              ]),
          ],
        ),
      ),
    );
  }
}

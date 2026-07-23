import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/word.dart';
import '../../../data/repositories/word_repository.dart';

/// 选词对话框（对照 selected-word.vue）。
///
/// 输入逗号分隔的词 -> find_words 查询 -> 按词文本分组（同字不同读音归为选项）
/// -> 选择读音 -> 返回选中的词列表。
class SelectWordDialog extends StatefulWidget {
  const SelectWordDialog({
    super.key,
    required this.wordRepository,
    this.initialWords = const <Word>[],
  });

  final WordRepository wordRepository;
  final List<Word> initialWords;

  @override
  State<SelectWordDialog> createState() => _SelectWordDialogState();
}

/// 分组行：一个词文本对应多个读音选项，current 为当前选中的词。
class _Row {
  _Row(this.text, this.options, this.current);
  final String text;
  final List<Word> options;
  Word current;
}

class _SelectWordDialogState extends State<SelectWordDialog> {
  final _textarea = TextEditingController();
  List<_Row> _rows = <_Row>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialWords.isNotEmpty) {
      _textarea.text = widget.initialWords.map((w) => w.text).join(',');
      WidgetsBinding.instance.addPostFrameCallback((_) => _find());
    }
  }

  @override
  void dispose() {
    _textarea.dispose();
    super.dispose();
  }

  List<String> get _parsed => _textarea.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _find() async {
    final list = _parsed;
    if (list.isEmpty) {
      showToast('请输入词');
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await widget.wordRepository.searchWords(list);
      // 按 text 分组。
      final map = <String, _Row>{};
      for (final w in results) {
        final existing = map[w.text];
        if (existing != null) {
          existing.options.add(w);
        } else {
          map[w.text] = _Row(w.text, [w], w);
        }
      }
      // 若为编辑场景，按初始词的原始拼音预选。
      for (final init in widget.initialWords) {
        final row = map[init.text];
        if (row != null) {
          final matched = row.options
              .where((o) => o.pinyinRaw == init.pinyinRaw)
              .toList();
          if (matched.isNotEmpty) row.current = matched.first;
        }
      }
      setState(() => _rows = map.values.toList());
    } on ApiException catch (e) {
      showToast(e.message);
    } catch (e) {
      showToast('查找失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _remove(_Row row) => setState(() => _rows.remove(row));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选词'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textarea,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '输入词，用英文逗号分隔',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('输入词：${_parsed.length} 个',
                    style: const TextStyle(fontSize: 12)),
                const Spacer(),
                FilledButton(
                  onPressed: _loading ? null : _find,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('查找'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Table: ${_rows.length} 条',
                style: const TextStyle(fontSize: 12, color: Colors.amber)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('读音')),
                    DataColumn(label: Text('词')),
                    DataColumn(label: Text('多音字')),
                    DataColumn(label: Text('释义')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: _rows
                      .map(
                        (row) => DataRow(cells: [
                          DataCell(Text('${row.current.id ?? ''}')),
                          DataCell(_ReadingSelector(
                            row: row,
                            onChanged: (w) =>
                                setState(() => row.current = w),
                          )),
                          DataCell(Text(row.text)),
                          DataCell(row.current.isPolyphone
                              ? const Text('是',
                                  style: TextStyle(color: Colors.green))
                              : const Text('否',
                                  style: TextStyle(color: Colors.grey))),
                          DataCell(ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 260),
                            child: Text(row.current.translation ?? '',
                                overflow: TextOverflow.ellipsis),
                          )),
                          DataCell(TextButton(
                            onPressed: () => _remove(row),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('删除'),
                          )),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(_rows.map((r) => r.current).toList());
                },
                child: const Text('确认添加'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 读音选择（对照 el-radio-group by pinyin_raw）。
class _ReadingSelector extends StatelessWidget {
  const _ReadingSelector({required this.row, required this.onChanged});
  final _Row row;
  final ValueChanged<Word> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: row.options.map((o) {
        final selected = o.pinyinRaw == row.current.pinyinRaw;
        return ChoiceChip(
          label: Text(o.pinyin ?? o.pinyinRaw ?? ''),
          selected: selected,
          visualDensity: VisualDensity.compact,
          onSelected: (_) => onChanged(o),
        );
      }).toList(),
    );
  }
}

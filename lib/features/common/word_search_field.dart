import 'package:flutter/material.dart';

import '../../data/models/word.dart';
import '../../data/repositories/word_repository.dart';

/// 远程选词控件（对照推荐弹窗中 el-select remote + handleWordChange）。
///
/// 选中后回调 wordId 与格式化文本 `[text] (pinyin)`。
class WordSearchField extends StatelessWidget {
  const WordSearchField({
    super.key,
    required this.wordRepository,
    required this.wordId,
    required this.wordText,
    required this.onSelected,
  });

  final WordRepository wordRepository;
  final int? wordId;
  final String wordText;
  final void Function(int wordId, String wordText) onSelected;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showDialog<Word>(
      context: context,
      builder: (_) => _WordPickerDialog(wordRepository: wordRepository),
    );
    if (result != null && result.id != null) {
      onSelected(result.id!, '[${result.text}] (${result.pinyin ?? ''})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '选择单词',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              wordId == null ? '请选择单词' : '$wordText (id: $wordId)',
              style: TextStyle(
                color: wordId == null ? Colors.grey : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openPicker(context),
          ),
        ],
      ),
    );
  }
}

class _WordPickerDialog extends StatefulWidget {
  const _WordPickerDialog({required this.wordRepository});
  final WordRepository wordRepository;

  @override
  State<_WordPickerDialog> createState() => _WordPickerDialogState();
}

class _WordPickerDialogState extends State<_WordPickerDialog> {
  final _query = TextEditingController();
  List<Word> _results = <Word>[];
  bool _loading = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final list = await widget.wordRepository.searchWords(<String>[q]);
      setState(() => _results = list);
    } catch (_) {
      setState(() => _results = <Word>[]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择单词'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '输入关键词',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final w = _results[i];
                        return ListTile(
                          dense: true,
                          title: Text('${w.text} (${w.pinyin ?? ''})'),
                          subtitle: Text('id: ${w.id ?? ''}'),
                          onTap: () => Navigator.of(context).pop(w),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

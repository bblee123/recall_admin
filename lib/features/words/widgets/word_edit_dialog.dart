import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/char_meta.dart';
import '../../../data/models/character.dart';
import '../../../data/models/variant.dart';
import '../../../data/models/word.dart';
import '../../../data/repositories/character_repository.dart';

/// 打开词汇创建/编辑弹窗（对照 words 的 el-dialog + CharMetaTable + wordDialogHooks）。
Future<void> showWordEditDialog(
  BuildContext context, {
  Word? initial,
  required CharacterRepository characterRepository,
  required Future<void> Function(Word word, bool isCreate) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _WordEditDialog(
      initial: initial,
      characterRepository: characterRepository,
      onSave: onSave,
    ),
  );
}

class _WordEditDialog extends StatefulWidget {
  const _WordEditDialog({
    this.initial,
    required this.characterRepository,
    required this.onSave,
  });

  final Word? initial;
  final CharacterRepository characterRepository;
  final Future<void> Function(Word word, bool isCreate) onSave;

  @override
  State<_WordEditDialog> createState() => _WordEditDialogState();
}

class _WordEditDialogState extends State<_WordEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _text;
  late final TextEditingController _pinyinRaw;
  late final TextEditingController _pinyin;
  late final TextEditingController _translation;

  List<CharMeta> _charMetas = <CharMeta>[];
  int _hasPolyphone = 0;
  bool _submitting = false;
  bool _loadingMeta = false;

  bool get _isCreate => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final w = widget.initial;
    _text = TextEditingController(text: w?.text ?? '');
    _pinyinRaw = TextEditingController(text: w?.pinyinRaw ?? '');
    _pinyin = TextEditingController(text: w?.pinyin ?? '');
    _translation = TextEditingController(text: w?.translation ?? '');
    _charMetas = List<CharMeta>.from(w?.charMetas ?? const <CharMeta>[]);
    _hasPolyphone = w?.hasPolyphone ?? 0;
  }

  @override
  void dispose() {
    _text.dispose();
    _pinyinRaw.dispose();
    _pinyin.dispose();
    _translation.dispose();
    super.dispose();
  }

  /// 对照 useCharMetaHook.mergeCharMeta：逐字对齐拼音，生成多音字元数据。
  Future<void> _getCharMeta() async {
    final text = _text.text.trim();
    final pinyinRaw = _pinyinRaw.text.trim();
    if (text.isEmpty || pinyinRaw.isEmpty) {
      showToast('请输入词汇, 原始拼音');
      return;
    }
    setState(() => _loadingMeta = true);
    try {
      final charItems = await widget.characterRepository.searchChars(text);
      final pinyinRawList = pinyinRaw.split(' ');
      final chars = text.split('');
      final metas = <CharMeta>[];
      final buffer = StringBuffer();
      for (var index = 0; index < chars.length; index++) {
        final char = chars[index];
        if (['', ',', '，'].contains(char.trim())) continue;
        CharItem? charItem;
        for (final it in charItems) {
          if (it.charText == char) {
            charItem = it;
            break;
          }
        }
        if (charItem == null) continue;
        final segPinyin =
            index < pinyinRawList.length ? pinyinRawList[index].trim() : null;
        Variant? variant;
        for (final v in charItem.variants) {
          if (v.charText == char && v.pinyinRaw == segPinyin) {
            variant = v;
            break;
          }
        }
        if (variant != null) {
          buffer.write('${variant.pinyin} ');
        }
        if (charItem.isPolyphone == 0) continue;
        if (variant != null) {
          metas.add(CharMeta(
            charText: char,
            pinyin: variant.pinyin,
            position: index,
          ));
        }
      }
      setState(() {
        _charMetas = metas;
        _hasPolyphone = metas.isNotEmpty ? 1 : 0;
        _pinyin.text = metas.isNotEmpty
            ? metas.map((m) => m.pinyin).join(' ')
            : buffer.toString().trim();
      });
    } on ApiException catch (e) {
      showToast(e.message);
    } catch (e) {
      showToast('搜索失败：$e');
    } finally {
      if (mounted) setState(() => _loadingMeta = false);
    }
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final word = Word(
      id: widget.initial?.id,
      text: _text.text.trim(),
      pinyin: _pinyin.text.trim(),
      pinyinRaw: _pinyinRaw.text.trim(),
      translation: _translation.text.trim(),
      hasPolyphone: _hasPolyphone,
      charMetas: _charMetas,
    );
    try {
      await widget.onSave(word, _isCreate);
      if (mounted) {
        showToast(_isCreate ? '创建成功' : '修改成功');
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      showToast(e.message);
    } catch (e) {
      showToast(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCreate ? '创建词汇' : '修改词汇'),
      content: SizedBox(
        width: 640,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _text,
                  decoration: const InputDecoration(
                    labelText: '词汇',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入词汇' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinyinRaw,
                  decoration: const InputDecoration(
                    labelText: '原始拼音',
                    helperText: '例：wen2（多字用空格分隔）',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入原始拼音' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinyin,
                  decoration: const InputDecoration(
                    labelText: '拼音',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入拼音' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('charMetas'),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: _loadingMeta ? null : _getCharMeta,
                      child: _loadingMeta
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Text('GetCharMeta'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _CharMetaTable(metas: _charMetas),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _translation,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '释义',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入释义' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('多音字'),
                    Switch(
                      value: _hasPolyphone == 1,
                      onChanged: (v) =>
                          setState(() => _hasPolyphone = v ? 1 : 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _confirm,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认'),
        ),
      ],
    );
  }
}

class _CharMetaTable extends StatelessWidget {
  const _CharMetaTable({required this.metas});
  final List<CharMeta> metas;

  @override
  Widget build(BuildContext context) {
    if (metas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
        child: const Text('暂无 charMetas', style: TextStyle(color: Colors.grey)),
      );
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('word_id')),
        DataColumn(label: Text('字')),
        DataColumn(label: Text('拼音')),
        DataColumn(label: Text('position')),
      ],
      rows: metas
          .map((m) => DataRow(cells: [
                DataCell(Text('${m.wordId ?? ''}')),
                DataCell(Text(m.charText)),
                DataCell(Text(m.pinyin)),
                DataCell(Text('${m.position}')),
              ]))
          .toList(),
    );
  }
}

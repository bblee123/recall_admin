import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../../core/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/book.dart';
import '../../../data/models/word.dart';
import '../../../data/repositories/word_repository.dart';
import '../../common/file_pick.dart';
import '../books_cubit.dart';
import 'select_word_dialog.dart';

/// 打开书籍全屏编辑弹窗（对照 admin-books 的 fullscreen el-dialog + useDialogHook）。
Future<void> showBookEditDialog(
  BuildContext context, {
  Book? initial,
  required BooksCubit cubit,
  required WordRepository wordRepository,
}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (_) => Dialog.fullscreen(
      child: _BookEditDialog(
        initial: initial,
        cubit: cubit,
        wordRepository: wordRepository,
      ),
    ),
  );
}

/// 可编辑单元。
class _EditableUnit {
  _EditableUnit({
    this.id,
    required this.title,
    required this.description,
    this.order = 0,
    List<Word>? words,
  })  : titleCtrl = TextEditingController(text: title),
        descCtrl = TextEditingController(text: description),
        words = words ?? <Word>[];

  final String? id;
  final String title;
  final String description;
  int order;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  List<Word> words;

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}

class _BookEditDialog extends StatefulWidget {
  const _BookEditDialog({
    this.initial,
    required this.cubit,
    required this.wordRepository,
  });

  final Book? initial;
  final BooksCubit cubit;
  final WordRepository wordRepository;

  @override
  State<_BookEditDialog> createState() => _BookEditDialogState();
}

class _BookEditDialogState extends State<_BookEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  bool _isFree = false;
  int _order = 0;
  String _coverUrl = '';
  File? _coverFile;
  final List<_EditableUnit> _units = <_EditableUnit>[];
  bool _submitting = false;
  bool _loadingUnits = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _title = TextEditingController(text: b?.title ?? '');
    _subtitle = TextEditingController(text: b?.subtitle ?? '');
    _isFree = b?.isFree ?? false;
    _order = b?.order ?? 0;
    _coverUrl = b?.coverUrl ?? '';
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final b = widget.initial;
    if (b == null || b.units.isEmpty) return;
    setState(() => _loadingUnits = true);
    for (final u in b.units) {
      var words = u.words ?? <Word>[];
      if (words.isEmpty && u.wordIds.isNotEmpty) {
        try {
          words = await widget.wordRepository.searchWords(u.wordIds);
        } catch (_) {
          words = <Word>[];
        }
      }
      _units.add(_EditableUnit(
        id: u.id,
        title: u.title,
        description: u.description ?? '',
        order: u.order,
        words: words,
      ));
    }
    if (mounted) setState(() => _loadingUnits = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    for (final u in _units) {
      u.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCover() async {
    final file = await pickImageFile();
    if (file != null) setState(() => _coverFile = file);
  }

  void _addUnit() {
    setState(() {
      _units.add(_EditableUnit(title: '', description: ''));
    });
  }

  void _removeUnit(_EditableUnit u) {
    setState(() {
      _units.remove(u);
      u.dispose();
    });
  }

  Future<void> _selectWords(_EditableUnit u) async {
    final result = await showDialog<List<Word>>(
      context: context,
      useSafeArea: false,
      builder: (_) => Dialog.fullscreen(
        child: SelectWordDialog(
          wordRepository: widget.wordRepository,
          initialWords: u.words,
        ),
      ),
    );
    if (result != null) {
      setState(() => u.words = result);
    }
  }

  List<BookUnit> _buildUnits() {
    return _units
        .map((u) => BookUnit(
              id: (u.id ?? '').isEmpty ? null : u.id,
              title: u.titleCtrl.text.trim(),
              description: u.descCtrl.text.trim(),
              order: u.order,
              wordIds: u.words
                  .where((w) => w.id != null)
                  .map((w) => w.id!)
                  .toList(),
            ))
        .toList();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isEdit) {
      if (_coverUrl.isEmpty && _coverFile == null) {
        showToast('请上传书籍封面');
        return;
      }
    } else if (_coverFile == null) {
      showToast('请上传书籍封面');
      return;
    }

    setState(() => _submitting = true);
    try {
      if (_isEdit) {
        await widget.cubit.updateBook(
          id: widget.initial!.id,
          title: _title.text.trim(),
          subtitle: _subtitle.text.trim(),
          coverUrl: _coverUrl,
          isFree: _isFree,
          order: _order,
          units: _buildUnits(),
          coverFile: _coverFile,
        );
      } else {
        await widget.cubit.createBook(
          title: _title.text.trim(),
          subtitle: _subtitle.text.trim(),
          isFree: _isFree,
          order: _order,
          units: _buildUnits(),
          coverFile: _coverFile!,
        );
      }
      if (mounted) {
        showToast('保存成功');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '修改书籍' : '添加书籍'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton(
              onPressed: _submitting ? null : _save,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEdit) ...[
                Text('id: ${widget.initial!.id}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
              ],
              const Text('封面'),
              const SizedBox(height: 8),
              _CoverPicker(
                coverUrl: _coverUrl,
                coverFile: _coverFile,
                onPick: _pickCover,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '请输入书籍标题' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitle,
                decoration: const InputDecoration(
                  labelText: '副标题',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '请输入书籍副标题' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('单元',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  FilledButton.tonal(
                      onPressed: _addUnit, child: const Text('添加单元')),
                ],
              ),
              const SizedBox(height: 8),
              if (_loadingUnits)
                const Center(child: CircularProgressIndicator())
              else
                ..._units.map(_buildUnitCard),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('是否免费'),
                  Switch(
                    value: _isFree,
                    onChanged: (v) => setState(() => _isFree = v),
                  ),
                  const SizedBox(width: 24),
                  const Text('Order'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: '$_order',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => _order = int.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard(_EditableUnit u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: u.titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '标题',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: u.descCtrl,
                    decoration: const InputDecoration(
                      labelText: '描述',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: '${u.order}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '排序',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => u.order = int.tryParse(v) ?? 0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeUnit(u),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonal(
                    onPressed: () => _selectWords(u),
                    child: const Text('选词')),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: u.words.isEmpty
                      ? null
                      : () => setState(() => u.words = <Word>[]),
                  child: const Text('清除'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: u.words
                  .map((w) => Chip(
                        label: Text('${w.text}:${w.pinyin ?? ''}'),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.coverUrl,
    required this.coverFile,
    required this.onPick,
  });

  final String coverUrl;
  final File? coverFile;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (coverFile != null) {
      preview = Image.file(coverFile!, fit: BoxFit.cover);
    } else if (coverUrl.isNotEmpty) {
      preview = Image.network(Env.r2Url(coverUrl), fit: BoxFit.cover);
    } else {
      preview = const Icon(Icons.add_a_photo, size: 32);
    }
    return InkWell(
      onTap: onPick,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(child: preview),
      ),
    );
  }
}

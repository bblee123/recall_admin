import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/variant.dart';

/// 打开释义创建/编辑弹窗（对照 dialogHooks + Home/variant 的 el-dialog 表单）。
///
/// [initial] 为空表示创建。[onSave] 由调用方执行仓库写入并刷新列表。
Future<void> showVariantEditDialog(
  BuildContext context, {
  Variant? initial,
  required Future<void> Function(Variant variant, bool isCreate) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _VariantEditDialog(initial: initial, onSave: onSave),
  );
}

class _VariantEditDialog extends StatefulWidget {
  const _VariantEditDialog({this.initial, required this.onSave});

  final Variant? initial;
  final Future<void> Function(Variant variant, bool isCreate) onSave;

  @override
  State<_VariantEditDialog> createState() => _VariantEditDialogState();
}

class _VariantEditDialogState extends State<_VariantEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _charText;
  late final TextEditingController _pinyin;
  late final TextEditingController _meaning;
  late final TextEditingController _samples;
  late final TextEditingController _pinyinRaw;
  late final TextEditingController _encAudio;
  bool _submitting = false;

  bool get _isCreate => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _charText = TextEditingController(text: v?.charText ?? '');
    _pinyin = TextEditingController(text: v?.pinyin ?? '');
    _meaning = TextEditingController(text: v?.meaning ?? '');
    _samples = TextEditingController(text: v?.samples ?? '');
    _pinyinRaw = TextEditingController(text: v?.pinyinRaw ?? '');
    _encAudio = TextEditingController(text: v?.encAudio ?? '');
  }

  @override
  void dispose() {
    _charText.dispose();
    _pinyin.dispose();
    _meaning.dispose();
    _samples.dispose();
    _pinyinRaw.dispose();
    _encAudio.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final variant = Variant(
      id: widget.initial?.id ?? 0,
      charText: _charText.text.trim(),
      pinyin: _pinyin.text.trim(),
      meaning: _meaning.text.trim(),
      samples: _samples.text.trim().isEmpty ? null : _samples.text.trim(),
      pinyinRaw: _pinyinRaw.text.trim(),
      encAudio: _encAudio.text.trim(),
    );
    try {
      await widget.onSave(variant, _isCreate);
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
      title: Text(_isCreate ? '创建汉字释义' : '修改汉字释义'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _charText,
                  enabled: _isCreate,
                  decoration: const InputDecoration(
                    labelText: '汉字',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入汉字' : null,
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
                TextFormField(
                  controller: _meaning,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '释义',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入释义' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _samples,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '例句',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinyinRaw,
                  decoration: const InputDecoration(
                    labelText: '原始拼音',
                    helperText: '例：wen2',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请输入原始拼音' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _encAudio,
                  decoration: const InputDecoration(
                    labelText: '音频名',
                    helperText: '音频名称，包含扩展名（不要随意改动）',
                    border: OutlineInputBorder(),
                  ),
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

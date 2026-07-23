import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/env.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../common/file_pick.dart';
import '../common/word_search_field.dart';
import 'base_recommendation_cubit.dart';
import 'base_recommendation_state.dart';

/// 默认推荐管理页（对照 admin-recommendation/base/index.vue）。
class BaseRecommendationPage extends StatelessWidget {
  const BaseRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BaseRecommendationCubit>(
      create: (context) =>
          BaseRecommendationCubit(context.read<RecommendationRepository>())
            ..load(),
      child: const _BaseView(),
    );
  }
}

class _BaseView extends StatelessWidget {
  const _BaseView();

  Future<void> _edit(BuildContext context, {BaseRecommendation? row}) async {
    final cubit = context.read<BaseRecommendationCubit>();
    final wordRepo = context.read<WordRepository>();
    await showDialog<void>(
      context: context,
      builder: (_) => _BaseEditDialog(
        cubit: cubit,
        wordRepository: wordRepo,
        initial: row,
        defaultDayIndex: row?.dayIndex ?? cubit.nextDayIndex,
      ),
    );
  }

  Future<void> _delete(BuildContext context, int dayIndex) async {
    final cubit = context.read<BaseRecommendationCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除吗？'),
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
    if (ok != true) return;
    try {
      await cubit.remove(dayIndex);
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
        child: BlocBuilder<BaseRecommendationCubit, BaseRecommendationState>(
          builder: (context, state) {
            final cubit = context.read<BaseRecommendationCubit>();
            final data = cubit.filtered;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 240,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '按单词搜索',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: cubit.setSearch,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _edit(context),
                      child: const Text('创建'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Text('错误：${state.error}',
                      style: const TextStyle(color: Colors.red)),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Day Index')),
                              DataColumn(label: Text('Word')),
                              DataColumn(label: Text('推荐图')),
                              DataColumn(label: Text('文本颜色')),
                              DataColumn(label: Text('季节')),
                              DataColumn(label: Text('操作')),
                            ],
                            rows: data.map((r) => _row(context, r)).toList(),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, BaseRecommendation r) {
    return DataRow(cells: [
      DataCell(Text('第 ${r.dayIndex} 天')),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('wordID: ${r.wordId ?? ''}'),
          Text('wordText: ${r.wordText}'),
        ],
      )),
      DataCell(r.imageKey.isEmpty
          ? const SizedBox(width: 40)
          : Image.network(
              Env.r2Url(r.imageKey),
              width: 40,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image, size: 20),
            )),
      DataCell(Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: _parseColor(r.textColor),
          ),
          const SizedBox(width: 6),
          Text(r.textColor),
        ],
      )),
      DataCell(Text(r.season)),
      DataCell(Row(
        children: [
          TextButton(
              onPressed: () => _edit(context, row: r),
              child: const Text('编辑')),
          TextButton(
            onPressed: () => _delete(context, r.dayIndex),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      )),
    ]);
  }
}

Color? _parseColor(String hex) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}

class _BaseEditDialog extends StatefulWidget {
  const _BaseEditDialog({
    required this.cubit,
    required this.wordRepository,
    required this.defaultDayIndex,
    this.initial,
  });

  final BaseRecommendationCubit cubit;
  final WordRepository wordRepository;
  final int defaultDayIndex;
  final BaseRecommendation? initial;

  @override
  State<_BaseEditDialog> createState() => _BaseEditDialogState();
}

class _BaseEditDialogState extends State<_BaseEditDialog> {
  late final TextEditingController _dayIndex;
  late final TextEditingController _textColor;
  int? _wordId;
  String _wordText = '';
  String _season = 'Spring';
  String _imageKey = '';
  File? _file;
  bool _submitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _dayIndex = TextEditingController(text: '${widget.defaultDayIndex}');
    _textColor = TextEditingController(text: r?.textColor ?? '#FFFFFF');
    _wordId = r?.wordId;
    _wordText = r?.wordText ?? '';
    _season = r?.season ?? 'Spring';
    _imageKey = r?.imageKey ?? '';
  }

  @override
  void dispose() {
    _dayIndex.dispose();
    _textColor.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await pickImageFile();
    if (file != null) setState(() => _file = file);
  }

  Future<void> _submit() async {
    final dayIndex = int.tryParse(_dayIndex.text.trim());
    if (dayIndex == null) {
      showToast('请输入推荐日期');
      return;
    }
    if (_wordId == null) {
      showToast('请选择推荐字');
      return;
    }
    if (_isEdit) {
      if (_file == null && _imageKey.isEmpty) {
        showToast('请上传图片');
        return;
      }
    } else if (_file == null) {
      showToast('请上传图片');
      return;
    }
    setState(() => _submitting = true);
    try {
      if (_isEdit) {
        await widget.cubit.update(
          dayIndex: dayIndex,
          wordId: _wordId,
          wordText: _wordText,
          textColor: _textColor.text.trim(),
          season: _season,
          file: _file,
        );
      } else {
        await widget.cubit.create(
          dayIndex: dayIndex,
          wordId: _wordId,
          wordText: _wordText,
          textColor: _textColor.text.trim(),
          season: _season,
          file: _file!,
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
    return AlertDialog(
      title: Text(_isEdit ? '编辑推荐基础' : '创建推荐基础'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('推荐图'),
              const SizedBox(height: 8),
              _ImagePicker(imageKey: _imageKey, file: _file, onPick: _pick),
              const SizedBox(height: 12),
              TextField(
                controller: _dayIndex,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Day Index',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              WordSearchField(
                wordRepository: widget.wordRepository,
                wordId: _wordId,
                wordText: _wordText,
                onSelected: (id, text) {
                  setState(() {
                    _wordId = id;
                    _wordText = text;
                  });
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Word Text',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(_wordText.isEmpty ? '-' : _wordText),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textColor,
                decoration: const InputDecoration(
                  labelText: '文本颜色',
                  helperText: '如 #FFFFFF',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _season,
                decoration: const InputDecoration(
                  labelText: '季节',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: kSeasons
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _season = v ?? 'Spring'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('确认'),
        ),
      ],
    );
  }
}

/// 图片选择/预览。
class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.imageKey,
    required this.file,
    required this.onPick,
  });

  final String imageKey;
  final File? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (file != null) {
      preview = Image.file(file!, fit: BoxFit.cover);
    } else if (imageKey.isNotEmpty) {
      preview = Image.network(Env.r2Url(imageKey), fit: BoxFit.cover);
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

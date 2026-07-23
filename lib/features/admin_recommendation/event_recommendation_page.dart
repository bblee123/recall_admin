import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/env.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../common/file_pick.dart';
import '../common/word_search_field.dart';
import 'event_recommendation_cubit.dart';
import 'event_recommendation_state.dart';

/// 节日推荐管理页（对照 admin-recommendation/event/index.vue）。
class EventRecommendationPage extends StatelessWidget {
  const EventRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventRecommendationCubit>(
      create: (context) =>
          EventRecommendationCubit(context.read<RecommendationRepository>())
            ..load(),
      child: const _EventView(),
    );
  }
}

class _EventView extends StatelessWidget {
  const _EventView();

  Future<void> _edit(BuildContext context, {EventRecommendation? row}) async {
    final cubit = context.read<EventRecommendationCubit>();
    final wordRepo = context.read<WordRepository>();
    await showDialog<void>(
      context: context,
      builder: (_) => _EventEditDialog(
        cubit: cubit,
        wordRepository: wordRepo,
        initial: row,
      ),
    );
  }

  Future<void> _delete(BuildContext context, String date) async {
    final cubit = context.read<EventRecommendationCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除吗？'),
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
      await cubit.remove(date);
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
        child: BlocBuilder<EventRecommendationCubit, EventRecommendationState>(
          builder: (context, state) {
            final cubit = context.read<EventRecommendationCubit>();
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
                  Text(
                    '错误：${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('推荐日期')),
                                DataColumn(label: Text('事件名')),
                                DataColumn(label: Text('推荐单词')),
                                DataColumn(label: Text('推荐图')),
                                DataColumn(label: Text('是否激活')),
                                DataColumn(label: Text('操作')),
                              ],
                              rows: data.map((r) => _row(context, r)).toList(),
                            ),
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

  DataRow _row(BuildContext context, EventRecommendation r) {
    return DataRow(
      cells: [
        DataCell(Text(r.specificDate)),
        DataCell(Text(r.eventName ?? '')),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('wordID: ${r.wordId ?? ''}'),
              Text('wordText: ${r.wordText}'),
            ],
          ),
        ),
        DataCell(
          r.imageKey.isEmpty
              ? const SizedBox(width: 40)
              : Image.network(
                  Env.r2Url(r.imageKey),
                  width: 40,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, size: 20),
                ),
        ),
        DataCell(Text(r.isActive ? '是' : '否')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => _edit(context, row: r),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => _delete(context, r.specificDate),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventEditDialog extends StatefulWidget {
  const _EventEditDialog({
    required this.cubit,
    required this.wordRepository,
    this.initial,
  });

  final EventRecommendationCubit cubit;
  final WordRepository wordRepository;
  final EventRecommendation? initial;

  @override
  State<_EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<_EventEditDialog> {
  late final TextEditingController _eventName;
  int? _wordId;
  String _wordText = '';
  String _specificDate = '';
  bool _isActive = true;
  String _imageKey = '';
  File? _file;
  bool _submitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _eventName = TextEditingController(text: r?.eventName ?? '');
    _wordId = r?.wordId;
    _wordText = r?.wordText ?? '';
    _specificDate = r?.specificDate ?? '';
    _isActive = r?.isActive ?? true;
    _imageKey = r?.imageKey ?? '';
  }

  @override
  void dispose() {
    _eventName.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await pickImageFile();
    if (file != null) setState(() => _file = file);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDate = now;
    if (_specificDate.isNotEmpty) {
      initialDate = DateTime.tryParse(_specificDate) ?? now;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _specificDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _submit() async {
    if (_specificDate.isEmpty) {
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
          specificDate: _specificDate,
          wordId: _wordId,
          wordText: _wordText,
          isActive: _isActive,
          eventName: _eventName.text.trim(),
          file: _file,
          imageKey: _file == null ? _imageKey : null,
        );
      } else {
        await widget.cubit.create(
          specificDate: _specificDate,
          wordId: _wordId,
          wordText: _wordText,
          isActive: _isActive,
          eventName: _eventName.text.trim(),
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
      title: Text(_isEdit ? '编辑节日推荐' : '创建节日推荐'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('推荐图'),
              const SizedBox(height: 8),
              _EventImagePicker(
                imageKey: _imageKey,
                file: _file,
                onPick: _pick,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _eventName,
                decoration: const InputDecoration(
                  labelText: '事件名',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '推荐日期',
                    border: OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(_specificDate.isEmpty ? '选择日期' : _specificDate),
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
              Row(
                children: [
                  const Text('是否激活'),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认'),
        ),
      ],
    );
  }
}

class _EventImagePicker extends StatelessWidget {
  const _EventImagePicker({
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

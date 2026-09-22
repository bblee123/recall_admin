import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recall_admin/core/audio/audio_service.dart';
import 'package:recall_admin/features/recorder/recorder_dialog.dart';
import 'package:recall_admin/features/recorder/service/recorder_options.dart';

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
  final R2AudioPlayer _audioPlayer = R2AudioPlayer.instance;

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
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
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

  Future<void> _play(Word w) async {
    await _audioPlayer.play(
      "https://pub-f83f97baa906439497f5a72d8696712d.r2.dev/word_audio/${w.id ?? ''}.mp3",
    );
    // final cubit = context.read<WordCubit>();
    // await cubit.playWord(w.id!);
  }

  Future<void> _openRecorder(Word w) async {
    final path = await showRecorderDialog(
      context,
      suggestName: '${w.id}_${w.text}',
      defaults: const RecorderOptions(
        sampleRate: SampleRateTier.rate48k,
        codec: RecorderCodec.wav,
        numChannels: 1,
        outputDir: "/Users/lipengfei/Documents/audio/words",
      ),
    );

    if (!mounted) return;
    if (path == null) {
      showToast('已取消录音');
      return;
    }
    final file = File(path);
    await context.read<WordRepository>().uploadAudio(file: file, wordId: w.id!);
    showToast('上传成功');
  }

  Future<void> _deleteAudio(Word w) async {
    // final cubit = context.read<WordCubit>();
    // try {
    //   await cubit.deleteAudio(w.id!);
    //   showToast('删除成功');
    // } on ApiException catch (e) {
    //   showToast(e.message);
    // }
  }

  @override
  void initState() {
    super.initState();
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
                      onPressed: cubit.searchNow,
                      child: const Text('搜索'),
                    ),
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
                    child: Text(
                      '错误：${state.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : _WordTable(
                            items: state.items,
                            onEdit: (w) => _edit(initial: w),
                            onDelete: _delete,
                            onPlay: _play,
                            onUpload: _openRecorder,
                            onDeleteAudio: _deleteAudio,
                          ),
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
    required this.onPlay,
    required this.onUpload,
    required this.onDeleteAudio,
    this.onGenerate,
  });

  final List<Word> items;
  final ValueChanged<Word> onEdit;
  final ValueChanged<Word> onDelete;
  final ValueChanged<Word> onPlay;
  final ValueChanged<Word> onUpload;
  final ValueChanged<Word> onDeleteAudio;
  final ValueChanged<Word>? onGenerate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('No.')),
          DataColumn(label: Text('词汇')),
          DataColumn(label: Text('音频')),
          DataColumn(label: Text('拼音')),
          DataColumn(label: Text('原始拼音')),
          DataColumn(label: Text('释义')),
          DataColumn(label: Text('多音字')),
          DataColumn(label: Text('操作')),
        ],
        rows: [
          for (var i = 0; i < items.length; i++)
            DataRow(
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(items[i].text)),
                DataCell(
                  _WordAudioCell(
                    word: items[i],
                    onPlay: onPlay,
                    onUpload: onUpload,
                    onDelete: onDeleteAudio,
                  ),
                ),
                DataCell(Text(items[i].pinyin ?? '')),
                DataCell(Text(items[i].pinyinRaw ?? '')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      items[i].translation ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  items[i].isPolyphone
                      ? const Chip(
                          label: Text('是'),
                          backgroundColor: Color(0xFFD7F5DD),
                          visualDensity: VisualDensity.compact,
                        )
                      : const Chip(
                          label: Text('否'),
                          visualDensity: VisualDensity.compact,
                        ),
                ),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => onEdit(items[i]),
                        child: const Text('修改'),
                      ),
                      TextButton(
                        onPressed: () => onDelete(items[i]),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WordAudioCell extends StatelessWidget {
  const _WordAudioCell({
    required this.word,
    required this.onPlay,
    required this.onUpload,
    required this.onDelete,
    this.onGenerate,
  });

  final Word word;
  final ValueChanged<Word> onPlay;
  final ValueChanged<Word> onUpload;
  final ValueChanged<Word> onDelete;
  final ValueChanged<Word>? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (word.hasAudio == 1) ...[
          IconButton(
            tooltip: '播放',
            icon: const Icon(Icons.play_circle, color: Colors.green, size: 20),
            onPressed: () => onPlay(word),
          ),
          IconButton(
            tooltip: '重新上传',
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => onUpload(word),
          ),
          IconButton(
            tooltip: '删除音频',
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            onPressed: () => onDelete(word),
          ),
        ] else
          IconButton(
            tooltip: '上传音频',
            icon: const Icon(Icons.upload_file, size: 18),
            onPressed: () => onUpload(word),
          ),

        if (onGenerate != null)
          IconButton(
            tooltip: 'AI 生成',
            icon: const Icon(
              Icons.auto_awesome,
              color: Colors.orange,
              size: 18,
            ),
            onPressed: () => onGenerate?.call(word),
          ),
      ],
    );
  }
}

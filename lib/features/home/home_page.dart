import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/audio/myenc_audio_service.dart';
import '../../core/env.dart';
import '../../data/models/character.dart';
import '../../data/models/variant.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/repositories/variant_repository.dart';
import '../../hanzi/hanzi_stroke.dart';
import '../../hanzi/hanzi_stroke_data.dart';
import '../common/meaning_text.dart';
import '../variant/widgets/variant_edit_dialog.dart';
import 'home_cubit.dart';
import 'home_state.dart';

/// 文字查询页（对照 Home.vue）。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) =>
          HomeCubit(context.read<CharacterRepository>())..search('文'),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _input = TextEditingController(text: '文');

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _search() => context.read<HomeCubit>().search(_input.text);

  Future<void> _playAudio(Variant v) async {
    final url =
        '${Env.apiBaseUrl}/media/audios/${v.charText}_${v.pinyinRaw}.myenc';
    try {
      await context.read<MyencAudioService>().playEncryptedUrl(url);
    } catch (e) {
      showToast('播放失败：$e');
    }
  }

  Future<void> _editVariant(Variant v) async {
    final repo = context.read<VariantRepository>();
    final cubit = context.read<HomeCubit>();
    await showVariantEditDialog(
      context,
      initial: v,
      onSave: (variant, isCreate) async {
        if (isCreate) {
          await repo.createVariant(variant);
        } else {
          await repo.updateVariant(variant);
        }
        await cubit.search(_input.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        final char = state.char;
        final variants = cubit.mergedVariants();
        final firstVariant = char != null && char.variants.isNotEmpty
            ? char.variants.first
            : null;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '[characters] join [character_variants] and [characters_strokes]',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _input,
                        decoration: const InputDecoration(
                          hintText: '请输入汉字',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: state.loading ? null : _search,
                      child: const Text('查询'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  Text('错误：${state.error}',
                      style: const TextStyle(color: Colors.red))
                else if (char != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StrokePanel(char: char),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstVariant != null
                                  ? '[${firstVariant.pinyin}]'
                                  : '',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text('部首：${char.radical}'),
                            Text('笔画：${char.strokeCount}'),
                            Text('多音：${char.polyphone ? '是' : '否'}'),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('释义：'),
                                Expanded(
                                  child: MeaningText(
                                    meaning: firstVariant?.meaning,
                                    showOne: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                if (char != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('此操作：不影响数据库　',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                      if (variants.isNotEmpty) ...[
                        const Text('完整释义'),
                        Switch(
                          value: state.mergeMeanings,
                          onChanged: cubit.toggleMerge,
                        ),
                        const Text('合并释义'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (variants.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('暂无数据'),
                      ),
                    )
                  else
                    _VariantTabs(
                      variants: variants,
                      activeId: state.activeVariantId,
                      merge: state.mergeMeanings,
                      onSelect: cubit.setActive,
                      onEdit: _editVariant,
                      onPlay: _playAudio,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 笔顺动画面板：字数据变化时自动播放整字动画。
class _StrokePanel extends StatefulWidget {
  const _StrokePanel({required this.char});
  final CharItem char;

  @override
  State<_StrokePanel> createState() => _StrokePanelState();
}

class _StrokePanelState extends State<_StrokePanel> {
  final HanziStrokeController _controller = HanziStrokeController(
    strokeAnimationDuration: const Duration(milliseconds: 600),
  );

  HanziStrokeData? _data;

  @override
  void initState() {
    super.initState();
    _rebuildData();
  }

  @override
  void didUpdateWidget(covariant _StrokePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.char.charText != widget.char.charText ||
        oldWidget.char.stroke != widget.char.stroke) {
      _rebuildData();
    }
  }

  void _rebuildData() {
    final map = widget.char.strokeMap;
    if (map == null) {
      setState(() => _data = null);
      return;
    }
    setState(() => _data = HanziStrokeData.fromMap(map));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.animateCharacter();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Column(
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: data == null
              ? const Center(child: Text('无笔画数据'))
              : HanziStrokeWidget(
                  data: data,
                  size: 220,
                  controller: _controller,
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '重播',
              icon: const Icon(Icons.replay),
              onPressed:
                  data == null ? null : () => _controller.animateCharacter(),
            ),
          ],
        ),
      ],
    );
  }
}

/// 释义分读音 Tab（对照 el-tabs）。
class _VariantTabs extends StatelessWidget {
  const _VariantTabs({
    required this.variants,
    required this.activeId,
    required this.merge,
    required this.onSelect,
    required this.onEdit,
    required this.onPlay,
  });

  final List<Variant> variants;
  final int? activeId;
  final bool merge;
  final ValueChanged<int> onSelect;
  final ValueChanged<Variant> onEdit;
  final ValueChanged<Variant> onPlay;

  @override
  Widget build(BuildContext context) {
    final active = variants.firstWhere(
      (v) => v.id == activeId,
      orElse: () => variants.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: variants.map((v) {
            final selected = v.id == active.id;
            return ChoiceChip(
              label: Text(v.pinyin),
              selected: selected,
              onSelected: (_) => onSelect(v.id),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${active.charText} [${active.pinyin}]',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (!merge) ...[
              IconButton(
                tooltip: '编辑',
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => onEdit(active),
              ),
              IconButton(
                tooltip: '播放',
                icon: const Icon(Icons.play_circle_outline, size: 20),
                onPressed: active.hasAudio ? () => onPlay(active) : null,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        MeaningText(meaning: active.meaning),
      ],
    );
  }
}

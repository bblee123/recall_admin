import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';

import 'core/audio/myenc_audio_service.dart';
import 'core/di.dart';
import 'core/router/app_router.dart';
import 'features/recorder/service/audio_recorder_service.dart';
import 'features/recorder/service/recorder_player_service.dart';
import 'features/recorder/service/recorder_sink.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/character_repository.dart';
import 'data/repositories/recommendation_repository.dart';
import 'data/repositories/variant_repository.dart';
import 'data/repositories/word_repository.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/login_dialog.dart';

class HanziToolApp extends StatefulWidget {
  const HanziToolApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<HanziToolApp> createState() => _HanziToolAppState();
}

class _HanziToolAppState extends State<HanziToolApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(
      repository: widget.deps.authRepository,
      tokenStorage: widget.deps.tokenStorage,
      deviceInfo: widget.deps.deviceInfo,
      session: widget.deps.session,
    );
    _router = buildRouter(
      tokenStorage: widget.deps.tokenStorage,
      session: widget.deps.session,
    );
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CharacterRepository>.value(
            value: deps.characterRepository),
        RepositoryProvider<WordRepository>.value(value: deps.wordRepository),
        RepositoryProvider<VariantRepository>.value(
            value: deps.variantRepository),
        RepositoryProvider<CategoryRepository>.value(
            value: deps.categoryRepository),
        RepositoryProvider<BookRepository>.value(value: deps.bookRepository),
        RepositoryProvider<RecommendationRepository>.value(
            value: deps.recommendationRepository),
        RepositoryProvider<MyencAudioService>.value(value: deps.audioService),
        RepositoryProvider<AudioRecorderService>.value(
            value: deps.recorderService),
        RepositoryProvider<RecorderPlayerService>.value(
            value: deps.recorderPlayer),
        RepositoryProvider<RecorderSink>.value(value: deps.recorderSink),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: _authCubit,
        child: OKToast(
          position: ToastPosition.bottom,
          child: MaterialApp.router(
            title: '汉字工具',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
            ),
            routerConfig: _router,
            builder: (context, child) {
              return Stack(
                children: [
                  ?child,
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (p, c) => p.dialogVisible != c.dialogVisible,
                    builder: (context, state) {
                      if (!state.dialogVisible) {
                        return const SizedBox.shrink();
                      }
                      return const Positioned.fill(child: LoginDialog());
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

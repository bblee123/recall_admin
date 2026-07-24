import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/recommendation_repository.dart';
import '../data/repositories/variant_repository.dart';
import '../data/repositories/word_repository.dart';
import '../features/recorder/service/audio_recorder_service.dart';
import '../features/recorder/service/recorder_player_service.dart';
import '../features/recorder/service/recorder_sink.dart';
import 'audio/myenc_audio_service.dart';
import 'network/dio_client.dart';
import 'network/session_controller.dart';
import 'storage/device_info.dart';
import 'storage/token_storage.dart';

/// 应用依赖容器：集中构造存储、网络、仓库与服务，供 UI 注入。
class AppDependencies {
  AppDependencies._({
    required this.tokenStorage,
    required this.deviceInfo,
    required this.session,
    required this.dioClient,
    required this.audioService,
    required this.recorderService,
    required this.recorderPlayer,
    required this.recorderSink,
    required this.characterRepository,
    required this.wordRepository,
    required this.variantRepository,
    required this.categoryRepository,
    required this.bookRepository,
    required this.recommendationRepository,
    required this.authRepository,
  });

  final TokenStorage tokenStorage;
  final DeviceInfo deviceInfo;
  final SessionController session;
  final DioClient dioClient;
  final MyencAudioService audioService;
  final AudioRecorderService recorderService;
  final RecorderPlayerService recorderPlayer;
  final RecorderSink recorderSink;

  final CharacterRepository characterRepository;
  final WordRepository wordRepository;
  final VariantRepository variantRepository;
  final CategoryRepository categoryRepository;
  final BookRepository bookRepository;
  final RecommendationRepository recommendationRepository;
  final AuthRepository authRepository;

  static Future<AppDependencies> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenStorage = TokenStorage(prefs);
    final deviceInfo = DeviceInfo(prefs);
    final session = SessionController();

    final dioClient = DioClient(
      tokenStorage: tokenStorage,
      deviceInfo: deviceInfo,
      session: session,
    );

    final audioService = MyencAudioService(dioClient.public);
    await audioService.ensureInitialized();

    final recorderService = AudioRecorderService();
    final recorderPlayer = RecorderPlayerService();
    // 默认本地转存；将来接 Cloudflare R2 时替换为 R2Sink。
    const recorderSink = LocalFileSink();

    return AppDependencies._(
      tokenStorage: tokenStorage,
      deviceInfo: deviceInfo,
      session: session,
      dioClient: dioClient,
      audioService: audioService,
      recorderService: recorderService,
      recorderPlayer: recorderPlayer,
      recorderSink: recorderSink,
      characterRepository: CharacterRepository(dioClient),
      wordRepository: WordRepository(dioClient),
      variantRepository: VariantRepository(dioClient),
      categoryRepository: CategoryRepository(dioClient),
      bookRepository: BookRepository(dioClient),
      recommendationRepository: RecommendationRepository(dioClient),
      authRepository: AuthRepository(dioClient),
    );
  }
}

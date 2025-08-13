import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/supabase_config.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/user_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/track_repository_provider.dart';
import 'utils/router.dart';
import 'constants/app_theme.dart';

Future<void> main() async {
  debugPrint('🚀 main() 함수 시작');
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Load environment variables FIRST (다른 모든 초기화에 필요)
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment variables loaded');
    
    // 2. 앱 환경 설정 초기화
    final environment = dotenv.env['APP_ENV'] == 'production' 
        ? Environment.production 
        : Environment.development;
    AppConfig.initialize(environment);
    debugPrint('✅ App config initialized: $environment');
    
    // 3. Supabase 초기화 (네트워크 연결 및 인증에 필요)
    await SupabaseConfig.initialize();
    debugPrint('✅ Supabase initialized successfully');
    
    // 4. Just Audio Background 초기화 (오디오 서비스에 필요)
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.everysleep.everysleep.audio',
      androidNotificationChannelName: 'EverySleep Audio',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: false,
    );
    debugPrint('✅ Audio background service initialized');
    
    // 5. 이미지 캐시 메모리 제한 설정 (메모리 최적화)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB 제한
    PaintingBinding.instance.imageCache.maximumSize = 20; // 최대 20개 이미지만 캐시
    
    debugPrint('✅ Supabase OAuth 사용으로 카카오 SDK 초기화 불필요');
    
  } catch (e) {
    debugPrint('❌ 초기화 오류: $e');
    // 오류 시에도 runApp 호출
  }

  debugPrint('🚀 runApp() 호출');
  runApp(const MyApp());
  debugPrint('✅ main() 함수 완료');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AudioProvider? _audioProvider;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 MyApp.initState() 시작');
    debugPrint('🚀 앱 초기화: Supabase OAuth 처리');
    
    // 앱 라이프사이클 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 앱 라이프사이클 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('🔄 앱 라이프사이클 변경: $state');
    
    // 오직 앱이 완전히 종료될 때만 오디오 정지
    if (state == AppLifecycleState.detached) {
      debugPrint('🔴 앱 완전 종료 (detached) - 오디오 정지');
      _stopAudioOnAppTermination();
    }
    // paused, resumed는 정상적인 백그라운드 사용이므로 음악 계속 재생
    else if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ 앱 백그라운드로 이동 - 음악 계속 재생');
    }
    else if (state == AppLifecycleState.resumed) {
      debugPrint('▶️ 앱 포그라운드로 복귀');
    }
  }


  void _stopAudioOnAppTermination() {
    try {
      debugPrint('🎵 앱 종료 - 강제 오디오 정지 실행');
      _audioProvider?.forceStopAll();
    } catch (e) {
      debugPrint('❌ 앱 종료 시 오디오 정지 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 MyApp.build() 시작');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuth(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) {
            _audioProvider = AudioProvider();
            return _audioProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TrackRepositoryProvider()),
      ],
      child: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return MaterialApp.router(
            title: 'EverySleep',
            theme: AppTheme.getLightTheme(fontSizeProvider.scaleFactor),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'), // 한국어
              Locale('en', 'US'), // 영어 (fallback)
            ],
            locale: const Locale('ko', 'KR'),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/user_provider.dart';
import 'providers/font_size_provider.dart';
import 'utils/router.dart';
import 'constants/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 카카오 SDK 초기화를 최우선으로
  const kakaoAppKey = String.fromEnvironment('KAKAO_APP_KEY', defaultValue: '2adb87534e7bf9098b2112040ce6167d');
  KakaoSdk.init(nativeAppKey: kakaoAppKey);
  debugPrint('카카오 SDK 초기화 완료');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  void _initAppLinks() {
    _appLinks = AppLinks();
    
    // 앱이 실행되지 않은 상태에서 링크로 시작된 경우
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('🔗 초기 링크로 앱 시작: $uri');
        _handleKakaoCallback(uri);
      }
    });
    
    // 앱이 실행 중일 때 링크를 받은 경우
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('🔗 실행 중 링크 수신: $uri');
      _handleKakaoCallback(uri);
    });
  }

  void _handleKakaoCallback(Uri uri) {
    debugPrint('🎯 카카오 콜백 처리: ${uri.toString()}');
    
    const kakaoAppKey = String.fromEnvironment('KAKAO_APP_KEY', defaultValue: '2adb87534e7bf9098b2112040ce6167d');
    if (uri.scheme == 'kakao$kakaoAppKey' && uri.host == 'oauth') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        debugPrint('✅ 카카오 OAuth 코드 수신: ${code.substring(0, 10)}...');
        // AuthProvider에 OAuth 코드 전달하여 토큰 교환 및 사용자 정보 획득
        _processOAuthCode(code);
      } else {
        debugPrint('❌ 카카오 OAuth 코드 없음');
      }
    }
  }

  Future<void> _processOAuthCode(String code) async {
    try {
      debugPrint('🔄 카카오 OAuth 성공으로 메인 화면 이동');
      
      // 짧은 딜레이 후 메인 화면으로 이동
      await Future.delayed(const Duration(milliseconds: 300));
      router.go('/main');
    } catch (e) {
      debugPrint('❌ OAuth 코드 처리 에러: $e');
      router.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return MaterialApp.router(
            title: 'EverySleep',
            theme: AppTheme.getLightTheme(fontSizeProvider.scaleFactor),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
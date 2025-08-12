import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final String appName = 'EverySleep';
  final String subtitle = '당신의 편안한 밤을 위해';

  List<Animation<double>> _letterAnimations = [];
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();

    // 텍스트 애니메이션 컨트롤러
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // 페이드 컨트롤러
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 각 글자에 대한 애니메이션 생성
    _createLetterAnimations();

    // 애니메이션만 시작 (AuthProvider는 이미 main.dart에서 초기화됨)
    _startAnimation();
  }

  void _createLetterAnimations() {
    _letterAnimations = [];
    for (int i = 0; i < appName.length; i++) {
      final start = (i * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);

      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );
    }
  }


  void _startAnimation() async {
    // mounted 체크 추가
    if (!mounted) return;

    // 1. 로고 페이드인
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // 2. 영어 글자별 등장 애니메이션
    await _textAnimationController.forward();

    if (!mounted) return;

    // 3. 잠시 대기
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // 4. 한글 서브타이틀 표시
    setState(() {
      _showSubtitle = true;
    });

    // 5. 위치 고정된 상태로 잠시 대기 후 다음 화면으로
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 6. 완료 후 다음 화면으로
    _finalizeAuthCheck();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }


  // 애니메이션 완료 후 인증 상태 확인 및 라우팅
  Future<void> _finalizeAuthCheck() async {
    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      
      debugPrint('📋 스플래시: 최종 라우팅 결정');
      debugPrint('📋 인증 상태: ${authProvider.isAuthenticated}');

      if (mounted) {
        if (authProvider.isAuthenticated) {
          debugPrint('✅ 인증됨 → 메인 화면');
          context.go('/main');
        } else {
          debugPrint('❌ 미인증 → 로그인 화면');
          context.go('/login');
        }
      }
    } catch (e) {
      debugPrint('❌ 라우팅 에러: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }


  void _skipToLogin() {
    // 이미 인증된 경우에만 스킵 차단
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      debugPrint('✅ 이미 인증됨 - 메인 화면으로 이동');
      context.go('/main');
      return;
    }

    if (mounted) {
      debugPrint('⏩ 스플래시 스킵 - 로그인 화면으로 이동');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _skipToLogin,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 애니메이션
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * _fadeAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: const AppLogo(size: 120, color: Colors.white),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // 애니메이션 앱 이름
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(appName.length, (index) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              50 *
                                  (1 - _letterAnimations[index].value).clamp(
                                    0.0,
                                    1.0,
                                  ),
                            ),
                            child: Transform.scale(
                              scale:
                                  0.3 +
                                  (0.7 *
                                      _letterAnimations[index].value.clamp(
                                        0.0,
                                        1.0,
                                      )),
                              child: Opacity(
                                opacity: (_letterAnimations[index].value).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Text(
                                  appName[index],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 3.5,
                                    shadows: [
                                      const Shadow(
                                        offset: Offset(0, 3),
                                        blurRadius: 12,
                                        color: Colors.black87,
                                      ),
                                      const Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 20,
                                        color: Colors.white24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // 서브타이틀 (자연스러운 페이드인만)
                  AnimatedOpacity(
                    opacity: _showSubtitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 10,
                            color: Colors.black87,
                          ),
                          Shadow(
                            offset: const Offset(0, 0),
                            blurRadius: 15,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

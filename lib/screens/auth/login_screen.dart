import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleKakaoLogin() async {
    debugPrint('카카오 로그인 버튼 클릭됨');
    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signInWithKakao();
      
      debugPrint('카카오 로그인 결과: $success');
      debugPrint('인증 상태: ${authProvider.isAuthenticated}');
      
      if (success && authProvider.isAuthenticated && mounted) {
        debugPrint('로그인 성공 - 메인 화면으로 이동');
        await Future.delayed(const Duration(milliseconds: 500)); // 짧은 딜레이
        if (mounted) {
          context.go('/main');
        }
      } else if (mounted) {
        debugPrint('로그인 실패 - 에러 메시지 표시');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카카오 로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('로그인 핸들러 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
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
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingXL * 3),
                  
                  // 앱 로고 및 제목
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const AppLogo(
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXL),
                        Text(
                          'EverySleep',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 3.0,
                            shadows: [
                              const Shadow(
                                offset: Offset(0, 3),
                                blurRadius: 15,
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
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          '편안한 수면을 위한 맞춤형 사운드',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.0,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL * 4),
                  
                  // 카카오 로그인 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE500),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFEE500).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: authProvider.isLoading ? null : _handleKakaoLogin,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF191919),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_medium.png',
                                        height: 26,
                                        width: 26,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '카카오 로그인',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF191919),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL * 2),
                  
                  // 하단 안내 텍스트  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '카카오 계정으로 간편하게 시작하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 6,
                            color: Colors.black54,
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
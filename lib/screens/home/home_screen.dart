import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/supabase_service.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/track_tile.dart';
import '../../models/theme.dart' as app_theme;
import '../../models/mood.dart';
import '../../models/track.dart';
import '../main_navigation.dart';
import '../../providers/track_repository_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Mood? _selectedMood;
  List<Mood> _moods = [];
  List<app_theme.Theme> _recommendedThemes = [];
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoadingMoods = true;
  
  // 기분별 색상 매핑
  final Map<String, Color> moodColorMap = {
    '기운이 없어요': const Color(0xFF50C878),
    '지쳤어요': const Color(0xFFFF7043),
    '귀에서 소리가 나요': const Color(0xFF5C6BC0),
    '푹 자고 싶어요': const Color(0xFF42A5F5),
    '낮잠이 필요해요': const Color(0xFF9C27B0),
    '조용히 쉬고싶어요': const Color(0xFF4CAF50),
    '기분 전환하고 싶어요': const Color(0xFFE91E63),
  };

  @override
  void initState() {
    super.initState();

    // 비동기 호출을 위젯 빌드 후로 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    _loadUserProfile();
    await _loadMoodsData();
    await _loadThemeData();
  }

  void _loadUserProfile() {
    final userProvider = context.read<UserProvider>();
    userProvider.loadUserProfile();
  }

  Future<void> _loadMoodsData() async {
    try {
      // 먼저 연결 테스트
      final isConnected = await _supabaseService.testConnection();
      if (!isConnected) {
        debugPrint('❌ Supabase 연결 실패');
        setState(() {
          _isLoadingMoods = false;
        });
        return;
      }

      final moods = await _supabaseService.getMoods();
      if (mounted) {
        setState(() {
          _moods = moods;
          _isLoadingMoods = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoods = false;
        });
        debugPrint('기분 데이터 로드 실패: $e');
        // 더 자세한 오류 정보 출력
        debugPrint('오류 타입: ${e.runtimeType}');
        debugPrint('오류 세부사항: ${e.toString()}');
      }
    }
  }

  Future<void> _loadThemeData() async {
    final themeProvider = context.read<ThemeProvider>();
    await themeProvider.initialize();

    // 기본 추천 테마 로드 (처음 4개)
    if (themeProvider.themes.isNotEmpty && _selectedMood == null) {
      setState(() {
        _recommendedThemes = themeProvider.themes.take(4).toList();
      });
    }
  }

  void _clearMoodSelection() async {
    setState(() {
      _selectedMood = null;
    });

    // 기본 추천 테마로 복원
    final themeProvider = context.read<ThemeProvider>();
    if (themeProvider.themes.isNotEmpty) {
      setState(() {
        _recommendedThemes = themeProvider.themes.take(4).toList();
      });
    }
  }

  void _selectMood(Mood mood) async {
    setState(() {
      _selectedMood = mood;
    });

    // 기분 기록 저장 (로그인된 경우에만) - 실패해도 계속 진행
    try {
      await _supabaseService.logUserMood(mood.id, null);
      debugPrint('✅ 기분 기록 저장 성공');
    } catch (e) {
      debugPrint('⚠️ 기분 기록 저장 실패 (로그인되지 않음): $e');
      // 에러를 무시하고 계속 진행
    }

    // 선택된 기분에 맞는 테마 필터링 (DB 관계 테이블 활용)
    try {
      if (mounted) {
        final themeProvider = context.read<ThemeProvider>();
        debugPrint('🔍 Searching themes for mood: "${mood.name}"');
        final filteredThemes = await themeProvider.getThemesByMood(mood.name);
        debugPrint(
          '📋 Found ${filteredThemes.length} themes for mood: "${mood.name}"',
        );
        for (var theme in filteredThemes) {
          debugPrint('   - ${theme.title} (${theme.trackCount}곡)');
        }

        if (filteredThemes.isNotEmpty && mounted) {
          setState(() {
            _recommendedThemes = filteredThemes.take(4).toList();
          });
        } else if (mounted) {
          // 해당 기분에 맞는 테마가 없는 경우 기본 테마 표시
          debugPrint(
            '⚠️ No themes found for mood: "${mood.name}" - using fallback',
          );
          final themeProvider = context.read<ThemeProvider>();
          if (themeProvider.themes.isNotEmpty) {
            setState(() {
              _recommendedThemes = themeProvider.themes.take(4).toList();
            });
            debugPrint(
              '📋 Fallback themes loaded: ${_recommendedThemes.length}개',
            );
            for (var theme in _recommendedThemes) {
              debugPrint('   - ${theme.title} (${theme.trackCount}곡)');
            }
          }
        }
      }
    } catch (e) {
      // 테마 필터링 실패시 에러 처리
      if (mounted) {
        debugPrint('❌ 테마 필터링 실패: $e');
        // 폴백: 기본 테마 표시
        final themeProvider = context.read<ThemeProvider>();
        if (themeProvider.themes.isNotEmpty) {
          setState(() {
            _recommendedThemes = themeProvider.themes.take(4).toList();
          });
        }
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요';
    } else if (hour < 18) {
      return '편안한 오후예요';
    } else {
      return '좋은 저녁이에요';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final nickname = userProvider.userProfile?.nickname ?? '사용자';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 인사 - 박스 없이 그냥 텍스트로
              Row(
                children: [
                  // 로고 컨테이너
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const AppLogo(size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$nickname님',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                                color: AppTheme.textPrimaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textSecondaryColor,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXL),

              // 건강팁 배너 (API 연동 예정)
              _buildHealthTipBanner(),
              const SizedBox(height: AppTheme.spacingXL),

              // 감정 선택 섹션
              Text(
                '오늘은 어떤 마음이신가요?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildEmotionSelector(),
              const SizedBox(height: AppTheme.spacingXL),

              // 추천 테마 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '추천 테마',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // MainNavigation의 추천음악 탭으로 이동
                      if (context
                              .findAncestorStateOfType<MainNavigationState>() !=
                          null) {
                        context
                            .findAncestorStateOfType<MainNavigationState>()!
                            .switchToTab(1);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      child: Text(
                        '전체보기',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildRecommendedThemes(),

              // 기분이 선택된 경우 관련 트랙들 표시
              if (_selectedMood != null && _recommendedThemes.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingXL),
                _buildSelectedMoodTracks(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    if (_isLoadingMoods) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_moods.isEmpty) {
      return const Center(child: Text('기분 데이터를 불러올 수 없습니다'));
    }

    // Wrap으로 변경하여 자동 줄바꿈 (벽돌 쌓기 방식)
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: _moods.map((mood) {
        final isSelected = _selectedMood?.id == mood.id;
        final color = moodColorMap[mood.name] ?? const Color(0xFF4CAF50);

        return GestureDetector(
          onTap: () {
            if (_selectedMood?.id == mood.id) {
              // 이미 선택된 기분을 다시 탭하면 선택 해제
              _clearMoodSelection();
            } else {
              // 새로운 기분 선택
              _selectMood(mood);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood.emoji ?? '😊', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  mood.name,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthTipBanner() {
    final healthTips = [
      {
        'title': '수면의 질을 높이는 팁',
        'content': '잠들기 2시간 전에는 화면을 보지 않고, 차분한 음악을 들어보세요.',
        'icon': '🌙',
      },
      {
        'title': '간단한 명상법',
        'content': '하루 10분, 깊은 호흡과 함께 마음을 차분하게 가라앉혀보세요.',
        'icon': '🧘‍♀️',
      },
      {
        'title': '스트레스 해소법',
        'content': '자연음을 들으며 가벼운 스트레칭으로 몸과 마음을 이완시켜보세요.',
        'icon': '🌿',
      },
    ];

    final currentTip = healthTips[DateTime.now().hour % healthTips.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            currentTip['icon'] as String,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTip['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentTip['content'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedThemes() {
    if (_recommendedThemes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 기분이 선택된 경우 1개의 큰 카드로 표시
    if (_selectedMood != null && _recommendedThemes.isNotEmpty) {
      return _buildSingleThemeCard(_recommendedThemes.first);
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: _recommendedThemes.asMap().entries.map((entry) {
        final theme = entry.value;

        return GestureDetector(
          onTap: () => _navigateToRecommendedMusic(theme),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 배경 이미지
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _getThemeBackgroundImage(theme).startsWith('assets/')
                            ? AssetImage(_getThemeBackgroundImage(theme)) as ImageProvider
                            : NetworkImage(_getThemeBackgroundImage(theme)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 오버레이
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // 콘텐츠
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${theme.trackCount}곡',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleThemeCard(theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _navigateToRecommendedMusic(theme),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 배경 이미지
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _getThemeBackgroundImage(theme).startsWith('assets/')
                            ? AssetImage(_getThemeBackgroundImage(theme)) as ImageProvider
                            : NetworkImage(_getThemeBackgroundImage(theme)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 오버레이
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  // 콘텐츠
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${theme.trackCount}곡',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          theme.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme.subtitle ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 테마별 배경 이미지 매핑 - 사람 없는 자연 이미지들, 각각 다른 이미지
  String _getThemeBackgroundImage(theme) {
    final themeTitle = theme.title?.toLowerCase() ?? '';
    
    // 구체적인 테마명으로 매핑
    if (themeTitle.contains('일상의 낭만')) {
      return 'assets/images/after.jpg'; // 일상의 낭만 - 따뜻한 거실 분위기
    } else if (themeTitle.contains('자연의 음악')) {
      return 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&h=300&fit=crop'; // 안개 낀 숲
    } else if (themeTitle.contains('이명케어')) {
      return 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=300&fit=crop'; // 고요한 호수
    } else if (themeTitle.contains('활력 부스터')) {
      return 'assets/images/hendrik-morkel-PEuBo_tBHDw-unsplash.jpg'; // 활력 부스터 - 산 정상의 활기찬 풍경
    } else if (themeTitle.contains('숙면테라피') || themeTitle.contains('숙면 테라피')) {
      return 'assets/images/quin-stevenson-3oyeaivM_fE-unsplash.jpg'; // 숙면테라피/숙면 테라피 - 평화로운 수면 환경
    } else if (themeTitle.contains('마음 테라피') || themeTitle.contains('마음테라피')) {
      return 'assets/images/h1.jpg'; // 마음 테라피 - 치유와 평안한 이미지
    } else if (themeTitle.contains('마음을 다독이며') || themeTitle.contains('다독')) {
      return 'assets/images/giulia-bertelli-dvXGnwnYweM-unsplash.jpg'; // 마음을 다독이며 - 따뜻하고 위로하는 이미지
    } else if (themeTitle.contains('수면') || themeTitle.contains('잠') || themeTitle.contains('꿈')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop'; // 구름 가득한 하늘
    } else if (themeTitle.contains('명상') || themeTitle.contains('평화') || themeTitle.contains('안정')) {
      return 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&h=300&fit=crop'; // 나무 그늘
    } else if (themeTitle.contains('활력') || themeTitle.contains('기분') || themeTitle.contains('햇살')) {
      return 'https://images.unsplash.com/photo-1441905436292-43cd83e8b5a4?w=400&h=300&fit=crop'; // 들판의 꽃
    } else if (themeTitle.contains('자연') || themeTitle.contains('숲') || themeTitle.contains('바람')) {
      return 'https://images.unsplash.com/photo-1428592953211-077101b2021b?w=400&h=300&fit=crop'; // 빗방울과 자연
    } else if (themeTitle.contains('재즈') || themeTitle.contains('카페') || themeTitle.contains('휴식')) {
      return 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400&h=300&fit=crop'; // 벚꽃 나무
    } else {
      // 기본 자연 이미지들을 ID에 따라 순환 사용 - 모두 다른 이미지
      final images = [
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400&h=300&fit=crop', // 새싹과 꽃
        'https://images.unsplash.com/photo-1516905365441-80295fccd862?w=400&h=300&fit=crop', // 따뜻한 자연광
        'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=400&h=300&fit=crop', // 별이 빛나는 밤
        'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=400&h=300&fit=crop', // 잔잔한 바다
        'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=400&h=300&fit=crop', // 은하수 밤하늘
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop', // 따뜻한 침실 창가
        'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=400&h=300&fit=crop', // 아늑한 카페 분위기
        'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400&h=300&fit=crop', // 차분한 저녁 분위기
      ];
      return images[(theme.id ?? 0) % images.length];
    }
  }

  // 테마별 차분한 모달 색상 매핑 - 시니어 친화적이고 화이트 텍스트와 잘 어울리는 색상
  Color _getThemeModalColor(theme) {
    // 테마 제목이나 ID에 따라 다른 색상 반환
    final themeTitle = theme.title?.toLowerCase() ?? '';
    final themeId = theme.id ?? 0;
    
    if (themeTitle.contains('수면') || themeTitle.contains('잠') || themeTitle.contains('꿈')) {
      return const Color(0xFF6B7A8A); // 차분한 청회색 - 수면 테마
    } else if (themeTitle.contains('명상') || themeTitle.contains('평화') || themeTitle.contains('안정')) {
      return const Color(0xFF7A8A7A); // 연한 올리브 그린 - 명상 테마
    } else if (themeTitle.contains('활력') || themeTitle.contains('기분') || themeTitle.contains('햇살')) {
      return const Color(0xFF8A7A6B); // 따뜻한 베이지 브라운 - 활력 테마
    } else if (themeTitle.contains('자연') || themeTitle.contains('숲') || themeTitle.contains('바람')) {
      return const Color(0xFF6B8A7A); // 자연스러운 그린 - 자연 테마
    } else if (themeTitle.contains('재즈') || themeTitle.contains('카페') || themeTitle.contains('휴식')) {
      return const Color(0xFF8A6B7A); // 차분한 와인 색 - 재즈/카페 테마
    } else {
      // ID를 기반으로 색상 선택 (일관성 유지)
      final colors = [
        const Color(0xFF6B7280), // 부드러운 회색
        const Color(0xFF7A6B8A), // 연한 보라
        const Color(0xFF8A7A6B), // 따뜻한 베이지
        const Color(0xFF6B8A7A), // 자연 그린
        const Color(0xFF8A6B7A), // 차분한 와인
      ];
      return colors[themeId % colors.length];
    }
  }

  void _navigateToRecommendedMusic(theme) {
    _showThemeDetailModal(theme);
  }

  void _showThemeDetailModal(theme) {
    // 테마별 차분한 모달 색상 - 시니어 친화적이고 화이트 텍스트와 조화로운 색상
    final modalColor = _getThemeModalColor(theme);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: modalColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 영역 - 단일 색상으로 통일
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${theme.trackCount}곡',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        theme.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme.subtitle ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (theme.description != null &&
                          theme.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          theme.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 트랙 리스트 영역
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: modalColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: FutureBuilder<List<Track>>(
                      future: _supabaseService.getTracksByTheme(theme),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '트랙을 불러오는 중...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '트랙이 없습니다',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        final themeTracks = snapshot.data!;
                        return ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(20),
                            itemCount: themeTracks.length,
                            itemBuilder: (context, index) {
                              final track = themeTracks[index];
                              return InkWell(
                                onTap: () async {
                                  // 플레이 로그 기록
                                  try {
                                    await _supabaseService.logUserPlay(
                                      trackId: track.id,
                                      themeId: theme.id,
                                    );
                                  } catch (e) {
                                    debugPrint('플레이 로그 기록 실패: $e');
                                  }

                                  if (!context.mounted) return;
                                  Navigator.of(context).pop(); // 모달 닫기
                                  // 플레이어 화면으로 이동 (track, theme, playlist 정보 전달)
                                  context.push(
                                    '/player',
                                    extra: {
                                      'track': track,
                                      'theme': theme,
                                      'playlist': themeTracks,
                                      'currentIndex': index,
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              track.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              track.artist,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                      },
                    ),
                  ),
                ),
                // 하단 버튼 영역
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedMoodTracks() {
    if (_recommendedThemes.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<List<Track>>(
      future: _loadTracksForSelectedThemes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('해당 기분에 맞는 트랙이 없습니다.'));
        }

        final selectedTracks = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추천 트랙',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedTracks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppTheme.spacingS),
              itemBuilder: (context, index) {
                final track = selectedTracks[index];
                return TrackTile(
                  track: track,
                  onTap: () => _playTrackFromMoodSelection(track, selectedTracks, index),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Track>> _loadTracksForSelectedThemes() async {
    final themeProvider = context.read<ThemeProvider>();
    List<Track> selectedTracks = [];

    try {
      for (var theme in _recommendedThemes) {
        final themeTracks = await _supabaseService.getTracksByTheme(theme);
        selectedTracks.addAll(themeTracks);
      }
    } catch (e) {
      debugPrint('트랙 조회 실패: $e');
      // 폴백: allTracks에서 처음 5개 선택
      selectedTracks = themeProvider.allTracks.take(5).toList();
    }

    // Repository에서 직접 정확한 데이터를 가져오므로 별도 이미지 업데이트 불필요

    return selectedTracks;
  }


  void _playTrackFromMoodSelection(Track track, List<Track> playlist, int currentIndex) async {
    try {
      // 플레이어 화면으로 이동
      if (mounted) {
        context.push('/player', extra: {
          'track': track,
          'playlist': playlist,
          'currentIndex': currentIndex,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('재생 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

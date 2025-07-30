import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/audio_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../utils/sample_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedEmotion;

  @override
  void initState() {
    super.initState();
    
    // 비동기 호출을 위젯 빌드 후로 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final userProvider = context.read<UserProvider>();
    userProvider.loadUserProfile();
  }

  void _selectEmotion(String emotion) {
    setState(() {
      _selectedEmotion = emotion;
    });
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
    final audioProvider = context.watch<AudioProvider>();
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2D3748),
                          const Color(0xFF1A202C),
                        ],
                      ),
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
                    child: const AppLogo(
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$nickname님',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    final emotions = [
      {'emoji': '😊', 'label': '활력', 'key': 'energy', 'color': const Color(0xFF50C878)}, // 활력적인 그린
      {'emoji': '😰', 'label': '스트레스', 'key': 'stress', 'color': const Color(0xFFFF7043)}, // 따뜻한 오렌지
      {'emoji': '😟', 'label': '불안', 'key': 'anxiety', 'color': const Color(0xFF5C6BC0)}, // 차분한 퍼플
      {'emoji': '😴', 'label': '수면', 'key': 'sleep', 'color': const Color(0xFF42A5F5)}, // 평온한 블루
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: emotions.map((emotion) {
          final isSelected = _selectedEmotion == emotion['key'];
          final color = emotion['color'] as Color;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _selectEmotion(emotion['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emotion['emoji'] as String,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      emotion['label'] as String,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHealthTipBanner() {
    final healthTips = [
      {
        'title': '수면의 질을 높이는 팁',
        'content': '잠들기 2시간 전에는 화면을 보지 않고, 차분한 음악을 들어보세요.',
        'icon': '🌙'
      },
      {
        'title': '간단한 명상법',
        'content': '하루 10분, 깊은 호흡과 함께 마음을 차분하게 가라앉혀보세요.',
        'icon': '🧘‍♀️'
      },
      {
        'title': '스트레스 해소법',
        'content': '자연음을 들으며 가벼운 스트레칭으로 몸과 마음을 이완시켜보세요.',
        'icon': '🌿'
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
    final themes = [
      {
        'title': '아침 명상',
        'subtitle': '하루를 시작하는 차분한 음악',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        'color': const Color(0xFF4A5568),
        'tracks': '12곡'
      },
      {
        'title': '숲속 산책',
        'subtitle': '자연의 소리와 함께하는 휴식',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
        'color': const Color(0xFF2D3748),
        'tracks': '18곡'
      },
      {
        'title': '바다의 평온',
        'subtitle': '파도 소리로 마음을 편안하게',
        'image': 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=300&fit=crop',
        'color': const Color(0xFF1A202C),
        'tracks': '15곡'
      },
      {
        'title': '달빛 수면',
        'subtitle': '깊은 잠에 빠져드는 선율',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        'color': const Color(0xFF2D3748),
        'tracks': '20곡'
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: themes.asMap().entries.map((entry) {
        final index = entry.key;
        final theme = entry.value;
        return GestureDetector(
          onTap: () async {
            // 테마별 트랙 로드하고 재생
            final tracks = SampleData.getAllTracks();
            final audioProvider = context.read<AudioProvider>();
            await audioProvider.loadPlaylist(tracks, startIndex: index % tracks.length);
            await audioProvider.play();
            if (mounted) {
              context.push('/player');
            }
          },
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
                  // 배경 이미지 (임시로 그라데이션 사용)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (theme['color'] as Color).withValues(alpha: 0.8),
                          (theme['color'] as Color).withValues(alpha: 0.6),
                        ],
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            theme['tracks'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme['subtitle'] as String,
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
}
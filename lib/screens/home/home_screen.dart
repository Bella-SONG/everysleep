import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/audio_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/track.dart';
import '../../utils/sample_data.dart';
import '../../widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedEmotion;
  List<Track> _recommendedTracks = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendedTracks();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final userProvider = context.read<UserProvider>();
    userProvider.loadUserProfile();
  }

  void _loadRecommendedTracks() {
    setState(() {
      _recommendedTracks = SampleData.getRecommendedTracks();
    });
  }

  void _selectEmotion(String emotion) {
    setState(() {
      _selectedEmotion = emotion;
      _recommendedTracks = SampleData.getTracksByEmotion(emotion);
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
              Text(
                '${_getGreeting()}, $nickname님',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '오늘의 기분은 어떠신가요?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildEmotionSelector(),
              const SizedBox(height: AppTheme.spacingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 추천 음악',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    child: const Text('전체보기'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildRecommendedTracks(audioProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    final emotions = [
      {'emoji': '😊', 'label': '활력이 필요해요', 'key': 'energy'},
      {'emoji': '😰', 'label': '스트레스 받아요', 'key': 'stress'},
      {'emoji': '😟', 'label': '불안해요', 'key': 'anxiety'},
      {'emoji': '😴', 'label': '잠이 안 와요', 'key': 'sleep'},
    ];

    return Wrap(
      spacing: AppTheme.spacingM,
      runSpacing: AppTheme.spacingM,
      children: emotions.map((emotion) {
        final isSelected = _selectedEmotion == emotion['key'];
        return InkWell(
          onTap: () => _selectEmotion(emotion['key'] as String),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emotion['emoji'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  emotion['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedTracks(AudioProvider audioProvider) {
    if (_recommendedTracks.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          '추천 음악을 불러오는 중...',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return Column(
      children: _recommendedTracks.map((track) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: TrackTile(
            track: track,
            onTap: () async {
              await audioProvider.loadTrack(track);
              await audioProvider.play();
              if (mounted) {
                context.push('/player');
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/audio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/track.dart';
import '../../providers/track_repository_provider.dart';
import '../../widgets/track_tile.dart';

class RecommendedMusicScreen extends StatefulWidget {
  const RecommendedMusicScreen({super.key});

  @override
  State<RecommendedMusicScreen> createState() => _RecommendedMusicScreenState();
}

class _RecommendedMusicScreenState extends State<RecommendedMusicScreen> {
  String _selectedCategory = '전체';
  List<Track> _tracks = [];
  List<String> _categories = [];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final trackRepositoryProvider = context.read<TrackRepositoryProvider>();

      // 카테고리와 초기 트랙을 병렬로 로드
      final futures = await Future.wait([
        trackRepositoryProvider.getEffectKeywordCategories(),
        trackRepositoryProvider.getTracksByEffectKeyword(_selectedCategory),
      ]);

      final categories = futures[0] as List<String>;
      final tracks = futures[1] as List<Track>;

      if (mounted) {
        setState(() {
          _categories = categories;
          _tracks = tracks;
        });
      }
    } catch (e) {
      debugPrint('초기 데이터 로딩 실패: $e');
    }
  }

  void _loadTracks() async {
    final themeProvider = context.read<ThemeProvider>();

    // 선택된 테마가 있는 경우 해당 테마의 트랙들을 로드
    if (themeProvider.selectedTheme != null) {
      // 테마별 트랙들이 이미 로드되어 있으면 사용, 없으면 다시 로드
      if (themeProvider.selectedThemeTracks.isNotEmpty) {
        setState(() {
          _tracks = themeProvider.selectedThemeTracks;
        });
      } else {
        await themeProvider.selectTheme(themeProvider.selectedTheme!);
        setState(() {
          _tracks = themeProvider.selectedThemeTracks;
        });
      }
      return;
    }

    // Repository를 사용한 비동기 데이터 로딩
    _loadTracksByCategory();
  }

  Future<void> _loadTracksByCategory() async {
    try {
      final trackRepositoryProvider = context.read<TrackRepositoryProvider>();
      // 새로운 효과 키워드 기반 카테고리 시스템 사용
      final tracks = await trackRepositoryProvider.getTracksByEffectKeyword(
        _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _tracks = tracks;
        });
      }
    } catch (e) {
      debugPrint('트랙 로딩 실패: $e');
      // 에러 처리 - 필요시 사용자에게 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(selectedTheme != null ? selectedTheme.title : '키워드별 음악'),
        automaticallyImplyLeading: false,
        actions: [
          if (selectedTheme != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // 선택된 테마 초기화
                themeProvider.clearSelection();
                _loadTracks();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (selectedTheme != null) _buildThemeHeader(selectedTheme),
          if (selectedTheme == null) _buildCategorySelector(),
          _buildStatsRow(),
          Expanded(child: _buildTrackList(audioProvider)),
        ],
      ),
    );
  }

  Widget _buildThemeHeader(theme) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '음원효과',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${theme.trackCount ?? 0}곡',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            theme.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_categories.isEmpty) {
      return const SizedBox(height: 50);
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                _loadTracksByCategory();
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalTracks = _tracks.length;
    final tracksWithBpm = _tracks.where((t) => t.bpm != null).toList();
    final avgBpm = tracksWithBpm.isNotEmpty
        ? tracksWithBpm.map((t) => t.bpm!).reduce((a, b) => a + b) /
              tracksWithBpm.length
        : 0.0;

    final totalDuration = _tracks
        .where((t) => t.durationSeconds != null)
        .fold<int>(0, (a, t) => a + t.durationSeconds!);

    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('총 $totalTracks곡', Icons.queue_music),
          if (tracksWithBpm.isNotEmpty)
            _buildStatItem('평균 ${avgBpm.round()}BPM', Icons.favorite),
          if (totalDuration > 0)
            _buildStatItem(
              hours > 0 ? '${hours}시간 ${minutes}분' : '${minutes}분',
              Icons.schedule,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackList(AudioProvider audioProvider) {
    if (_tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '이 카테고리에 음악이 없습니다',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: TrackTile(
            track: track,
            onTap: () async {
              await audioProvider.loadPlaylist(_tracks, startIndex: index);
              await audioProvider.play();
              if (mounted) {
                context.push('/player');
              }
            },
          ),
        );
      },
    );
  }
}

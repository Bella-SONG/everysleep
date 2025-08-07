import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../constants/app_theme.dart';
import '../../models/theme.dart' as app_theme;
import '../../models/track.dart';

class ThemeDetailScreen extends StatefulWidget {
  final int themeId;
  
  const ThemeDetailScreen({
    super.key,
    required this.themeId,
  });

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  app_theme.Theme? _theme;
  List<Track> _tracks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThemeData();
  }

  Future<void> _loadThemeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 테마 정보 로드
      final theme = await _supabaseService.getThemeById(widget.themeId);
      if (theme == null) {
        setState(() {
          _error = '테마를 찾을 수 없습니다';
          _isLoading = false;
        });
        return;
      }

      // 테마의 트랙들 로드
      final tracks = await _supabaseService.getTracksByThemeId(widget.themeId);

      if (mounted) {
        setState(() {
          _theme = theme;
          _tracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '데이터를 불러오는데 실패했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바
            _buildAppBar(),
            
            // 컨텐츠 영역
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Expanded(
            child: Text(
              _theme?.title ?? '테마 상세',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // 뒤로가기 버튼과 균형 맞추기
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadThemeData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_theme == null) {
      return const Center(
        child: Text('테마 정보가 없습니다'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 테마 헤더
          _buildThemeHeader(),
          const SizedBox(height: AppTheme.spacingXL),
          
          // 트랙 리스트
          _buildTrackList(),
        ],
      ),
    );
  }

  Widget _buildThemeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
          Text(
            _theme!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          if (_theme!.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _theme!.subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _theme!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_tracks.length}곡',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    if (_tracks.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '이 테마에는 음원이 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '음원 목록',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tracks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final track = _tracks[index];
            return _buildTrackTile(track, index);
          },
        ),
      ],
    );
  }

  Widget _buildTrackTile(Track track, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            track.isAsmr ? Icons.headphones : Icons.music_note,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          track.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.artist,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (track.durationSeconds != null) ...[
              const SizedBox(height: 4),
              Text(
                track.formattedDuration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (track.bpm != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${track.bpm} BPM',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              onPressed: () => _playTrack(track),
              icon: const Icon(
                Icons.play_arrow,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        onTap: () => _playTrack(track),
      ),
    );
  }

  void _playTrack(Track track) async {
    try {
      // 플레이 로그 기록
      await _supabaseService.logUserPlay(
        trackId: track.id,
        themeId: _theme?.id,
      );

      // 플레이어 화면으로 이동 (track 정보를 extra로 전달)
      if (mounted) {
        context.push('/player', extra: {
          'track': track,
          'theme': _theme,
          'playlist': _tracks,
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
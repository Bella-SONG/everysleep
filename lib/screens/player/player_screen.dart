import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/audio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/sleep_timer_dialog.dart';
import '../../widgets/nature_sound_selector.dart';
import '../../widgets/track_feedback_dialog.dart';
import '../../services/feedback_service.dart';
import '../../config/app_config.dart';
import '../../config/supabase_config.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool? _hasGivenFeedback; // null: 아직 안함, true: 좋아요, false: 싫어요
  
  @override
  void initState() {
    super.initState();
    _loadTrackFromRoute();
    _setupFeedbackCallback();
    _testDatabaseConnection();
  }

  void _testDatabaseConnection() async {
    final isConnected = await FeedbackService.testDatabaseConnection();
    print('📊 데이터베이스 연결 상태: ${isConnected ? '성공' : '실패'}');
  }

  void _setupFeedbackCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = context.read<AudioProvider>();
      audioProvider.setTrackCompletedCallback((track) {
        _showFeedbackDialog(track);
      });
    });
  }

  void _showFeedbackDialog(dynamic track) {
    if (!mounted) return;
    
    // 이미 빠른 피드백을 줬으면 상세 다이얼로그 생략
    if (_hasGivenFeedback != null) {
      return;
    }
    
    _showFeedbackDialogWithInitialValue(track, null);
  }

  void _showFeedbackDialogWithInitialValue(dynamic track, bool? initialIsPositive) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => TrackFeedbackDialog(
        track: track,
        initialIsPositive: initialIsPositive,
        onSubmitFeedback: (feedback) async {
          // 피드백을 서버에 저장
          final success = await FeedbackService.submitFeedback(feedback);
          if (mounted) {
            // 피드백 완료 후 즉시 상태 리셋
            setState(() {
              _hasGivenFeedback = null;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success 
                    ? '피드백이 저장되었습니다'
                    : '피드백 저장에 실패했습니다'),
                backgroundColor: success 
                    ? AppTheme.successColor 
                    : AppTheme.errorColor,
              ),
            );
          }
        },
      ),
    );
  }

  void _quickFeedback(bool isPositive) {
    final audioProvider = context.read<AudioProvider>();
    final track = audioProvider.currentTrack;
    
    if (track == null) {
      print('❌ 빠른 피드백 실패: 현재 트랙이 없음');
      return;
    }
    
    print('🎵 빠른 피드백 시작: ${track.title} (${isPositive ? '👍' : '👎'})');
    
    // 피드백 모달 띄우기 (초기값 설정)
    _showFeedbackDialogWithInitialValue(track, isPositive);
  }

  void _loadTrackFromRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeState = GoRouterState.of(context);
      final extra = routeState.extra as Map<String, dynamic>?;
      
      if (extra != null) {
        final track = extra['track'];
        final playlist = extra['playlist'] as List?;
        final currentIndex = extra['currentIndex'] as int?;
        final theme = extra['theme'];  // 테마 정보 받기
        
        // 테마 정보가 있으면 ThemeProvider에 설정
        if (theme != null) {
          final themeProvider = context.read<ThemeProvider>();
          // selectedTheme이 null이거나 다른 테마일 때만 설정
          if (themeProvider.selectedTheme?.id != theme.id) {
            themeProvider.selectTheme(theme);
          }
        }
        
        if (track != null) {
          // 새 트랙 로드시 피드백 상태 리셋
          setState(() {
            _hasGivenFeedback = null;
          });
          
          final audioProvider = context.read<AudioProvider>();
          if (playlist != null && playlist.isNotEmpty) {
            // currentIndex가 있으면 해당 인덱스부터 시작, 없으면 0부터
            audioProvider.loadPlaylist(List.from(playlist), startIndex: currentIndex ?? 0);
          } else {
            audioProvider.loadTrack(track);
          }
          audioProvider.play();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final track = audioProvider.currentTrack;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('재생 중인 음악이 없습니다'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getTrackImageProvider(track),
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
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 커스텀 앱바
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.timer_outlined, color: Colors.white),
                        onPressed: () => _showSleepTimerDialog(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      children: [
                        const SizedBox(height: AppTheme.spacingXL * 3), // 상단 여백
                        _buildTrackInfo(context, track),
                        const SizedBox(height: AppTheme.spacingXL * 2),
                        _buildProgressBar(context, audioProvider),
                        const SizedBox(height: AppTheme.spacingXL),
                        _buildControls(context, audioProvider),
                        const SizedBox(height: AppTheme.spacingXL),
                        if (AppConfig.showQuickFeedback) _buildQuickFeedback(context),
                        if (AppConfig.showQuickFeedback) const SizedBox(height: AppTheme.spacingXL),
                        _buildVolumeControls(context, audioProvider),
                        const SizedBox(height: 120), // 자연음 선택기를 위한 여백
                      ],
                    ),
                  ),
                ),
                const NatureSoundSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTrackInfo(BuildContext context, track) {
    return Column(
      children: [
        Text(
          track.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          track.artist,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, AudioProvider audioProvider) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: audioProvider.position.inSeconds.toDouble(),
            max: audioProvider.duration.inSeconds.toDouble(),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            onChanged: (value) {
              audioProvider.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioProvider.position),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              Text(
                _formatDuration(audioProvider.duration),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, AudioProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            audioProvider.isRepeatOne
                ? Icons.repeat_one
                : Icons.repeat,
            color: audioProvider.isRepeatOne
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.7),
          ),
          iconSize: 28,
          onPressed: audioProvider.toggleRepeatOne,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 40,
          onPressed: audioProvider.hasPrevious
              ? audioProvider.skipToPrevious
              : null,
        ),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 40,
            onPressed: () {
              if (audioProvider.isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.play();
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 40,
          onPressed: audioProvider.hasNext
              ? audioProvider.skipToNext
              : null,
        ),
        IconButton(
          icon: Icon(
            Icons.nightlight_round,
            color: audioProvider.sleepTimerDuration != null
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.7),
          ),
          iconSize: 28,
          onPressed: () => _showSleepTimerDialog(context),
        ),
      ],
    );
  }

  Widget _buildVolumeControls(BuildContext context, AudioProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, size: 20, color: Colors.white),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: audioProvider.musicVolume,
                    onChanged: audioProvider.setMusicVolume,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Text(
                '${(audioProvider.musicVolume * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 20, color: Colors.white),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: audioProvider.natureVolume,
                    onChanged: audioProvider.setNatureVolume,
                    activeColor: AppTheme.secondaryColor,
                    inactiveColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Text(
                '${(audioProvider.natureVolume * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
  }

  Widget _buildQuickFeedback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 좋아요 버튼
          Expanded(
            child: Material(
              color: _hasGivenFeedback == true
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _quickFeedback(true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasGivenFeedback == true
                          ? Colors.green
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: _hasGivenFeedback == true
                            ? Colors.green
                            : Colors.white.withValues(alpha: 0.8),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '좋아요',
                        style: TextStyle(
                          color: _hasGivenFeedback == true
                              ? Colors.green
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: _hasGivenFeedback == true
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 싫어요 버튼
          Expanded(
            child: Material(
              color: _hasGivenFeedback == false
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _quickFeedback(false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasGivenFeedback == false
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thumb_down,
                        color: _hasGivenFeedback == false
                            ? Colors.red
                            : Colors.white.withValues(alpha: 0.8),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '별로예요',
                        style: TextStyle(
                          color: _hasGivenFeedback == false
                              ? Colors.red
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: _hasGivenFeedback == false
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ImageProvider _getTrackImageProvider(dynamic track) {
    // Supabase Storage에서 이미지 가져오기 (곡 파일명 기반)
    if (track.fileName != null) {
      // 파일명에서 확장자 제거하고 소문자로 변환 후 .jpg로 매핑
      final filenameWithoutExt = track.fileName.split('.').first.toLowerCase();
      final imagePath = '$filenameWithoutExt.jpg';
      final imageUrl = SupabaseConfig.getImageUrl(imagePath);
      return CachedNetworkImageProvider(imageUrl);
    }
    
    // 기본 이미지
    return const AssetImage('assets/images/sleep1.png');
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/audio_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/sleep_timer_dialog.dart';
import '../../widgets/nature_sound_selector.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrackFromRoute();
  }

  void _loadTrackFromRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeState = GoRouterState.of(context);
      final extra = routeState.extra as Map<String, dynamic>?;
      
      if (extra != null) {
        final track = extra['track'];
        final playlist = extra['playlist'] as List?;
        final currentIndex = extra['currentIndex'] as int?;
        
        if (track != null) {
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
            image: track.thumbnail?.startsWith('assets/') == true
                ? AssetImage(track.thumbnail!) as ImageProvider
                : CachedNetworkImageProvider(track.thumbnail ?? ''),
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
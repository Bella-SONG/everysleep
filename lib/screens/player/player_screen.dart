import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/audio_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/sleep_timer_dialog.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => _showSleepTimerDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAlbumArt(track.thumbnail),
                    const SizedBox(height: AppTheme.spacingXL),
                    _buildTrackInfo(context, track),
                    const SizedBox(height: AppTheme.spacingXL),
                    _buildProgressBar(context, audioProvider),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildControls(context, audioProvider),
                  ],
                ),
              ),
              _buildVolumeControls(context, audioProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(String thumbnail) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: CachedNetworkImage(
          imageUrl: thumbnail,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.music_note,
              size: 100,
              color: AppTheme.primaryColor,
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
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          track.artist,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
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
            inactiveColor: AppTheme.primaryColor.withOpacity(0.2),
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _formatDuration(audioProvider.duration),
                style: Theme.of(context).textTheme.bodyMedium,
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
                : AppTheme.textSecondaryColor,
          ),
          iconSize: 28,
          onPressed: audioProvider.toggleRepeatOne,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous),
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
                color: AppTheme.primaryColor.withOpacity(0.3),
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
          icon: const Icon(Icons.skip_next),
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
                : AppTheme.textSecondaryColor,
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
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, size: 20),
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
                    inactiveColor: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              Text(
                '${(audioProvider.musicVolume * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 20),
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
                    inactiveColor: AppTheme.secondaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              Text(
                '${(audioProvider.natureVolume * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium,
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
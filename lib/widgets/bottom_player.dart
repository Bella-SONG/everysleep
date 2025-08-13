import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/audio_provider.dart';
import '../constants/app_theme.dart';
import '../config/supabase_config.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  Widget _buildThumbnailImage(dynamic track) {
    // Supabase Storage에서 썸네일 이미지 가져오기 (곡 파일명 기반)
    if (track.fileName != null) {
      final filenameWithoutExt = track.fileName!.split('.').first.toLowerCase();
      final imagePath = '$filenameWithoutExt.jpg';
      final imageUrl = SupabaseConfig.getThumbnailUrl(imagePath);
      
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        memCacheWidth: 96, // 메모리 캐시 크기 제한
        memCacheHeight: 96,
        placeholder: (context, url) => Container(
          width: 48,
          height: 48,
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 48,
          height: 48,
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(
            Icons.music_note,
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }
    
    // 기본 이미지
    return Container(
      width: 48,
      height: 48,
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: const Icon(
        Icons.music_note,
        color: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final track = audioProvider.currentTrack;

    if (track == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: _buildThumbnailImage(track),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      track.artist,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 32,
                    onPressed: () {
                      if (audioProvider.isPlaying) {
                        audioProvider.pause();
                      } else {
                        audioProvider.play();
                      }
                    },
                  ),
                  if (audioProvider.hasNext)
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 28,
                      onPressed: audioProvider.skipToNext,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/track.dart';
import '../constants/app_theme.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final bool showDuration;
  final bool showBpm;
  final bool showEffectKeywords;
  final bool showRanking;
  final int? ranking;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.showDuration = true,
    this.showBpm = true,
    this.showEffectKeywords = true,
    this.showRanking = false,
    this.ranking,
  });

  Widget _buildTrackImage() {
    // track_details 뷰에서 직접 썸네일 URL 사용
    if (track.thumbnail != null && track.thumbnail!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: track.thumbnail!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        memCacheWidth: 120, // 메모리 캐시 크기 제한 (실제 크기의 2배)
        memCacheHeight: 120,
        placeholder: (context, url) => Container(
          width: 60,
          height: 60,
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 60,
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            track.isAsmr ? Icons.headphones : Icons.music_note,
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }
    
    // 기본 이미지
    return Container(
      width: 60,
      height: 60,
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Icon(
        track.isAsmr ? Icons.headphones : Icons.music_note,
        color: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
            if (showRanking && ranking != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ranking! <= 3 
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ranking! <= 3 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$ranking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ranking! <= 3 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: _buildTrackImage(),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
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
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Row(
                    children: [
                      if (showDuration && track.durationSeconds != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          track.formattedDuration,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (showBpm && track.bpm != null) ...[
                        if (showDuration && track.durationSeconds != null) 
                          const SizedBox(width: 8),
                        Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${track.bpm}BPM',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (track.category != null && track.category!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            track.category!,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showEffectKeywords && track.effectKeywords.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: track.effectKeywords.map((keyword) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            keyword,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.play_circle_filled,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
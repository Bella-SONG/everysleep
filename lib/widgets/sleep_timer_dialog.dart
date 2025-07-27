import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../constants/app_theme.dart';

class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final currentTimer = audioProvider.sleepTimerDuration;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  '수면 타이머',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            if (currentTimer != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '타이머 활성화됨',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getRemainingTime(audioProvider.sleepTimerEndTime),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
            _buildTimerOption(context, '15분', const Duration(minutes: 15)),
            _buildTimerOption(context, '30분', const Duration(minutes: 30)),
            _buildTimerOption(context, '1시간', const Duration(hours: 1)),
            _buildTimerOption(context, '2시간', const Duration(hours: 2)),
            if (currentTimer != null) ...[
              const Divider(height: AppTheme.spacingL),
              TextButton(
                onPressed: () {
                  audioProvider.cancelSleepTimer();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('타이머 취소'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerOption(
    BuildContext context,
    String label,
    Duration duration,
  ) {
    return InkWell(
      onTap: () {
        context.read<AudioProvider>().setSleepTimer(duration);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getRemainingTime(DateTime? endTime) {
    if (endTime == null) return '';
    
    final remaining = endTime.difference(DateTime.now());
    if (remaining.isNegative) return '종료됨';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분 남음';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초 남음';
    } else {
      return '${seconds}초 남음';
    }
  }
}
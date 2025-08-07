import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/track.dart';
import '../../widgets/track_tile.dart';

class PopularTracksScreen extends StatefulWidget {
  const PopularTracksScreen({super.key});

  @override
  State<PopularTracksScreen> createState() => _PopularTracksScreenState();
}

class _PopularTracksScreenState extends State<PopularTracksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimaryColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '인기 트랙',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: themeProvider.allTracks.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              itemCount: themeProvider.allTracks.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingM),
              itemBuilder: (context, index) {
                final track = themeProvider.allTracks[index];
                return TrackTile(
                  track: track,
                  onTap: () => _playTrack(track),
                  showRanking: true,
                  ranking: index + 1,
                );
              },
            ),
    );
  }

  void _playTrack(Track track) {
    try {
      if (mounted) {
        context.push('/player', extra: {
          'track': track,
          'playlist': context.read<ThemeProvider>().allTracks,
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
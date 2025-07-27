import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/audio_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/track.dart';
import '../../utils/sample_data.dart';
import '../../widgets/track_tile.dart';

class RecommendedMusicScreen extends StatefulWidget {
  const RecommendedMusicScreen({super.key});

  @override
  State<RecommendedMusicScreen> createState() => _RecommendedMusicScreenState();
}

class _RecommendedMusicScreenState extends State<RecommendedMusicScreen> {
  String _selectedCategory = '추천';
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  void _loadTracks() {
    setState(() {
      if (_selectedCategory == '추천') {
        _tracks = SampleData.getRecommendedTracks();
      } else {
        _tracks = SampleData.getTracksByCategory(_selectedCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('추천 음악'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: _buildTrackList(audioProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = SampleData.getCategories();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _loadTracks();
                });
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
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
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
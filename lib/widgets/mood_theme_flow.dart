import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../models/theme.dart' as app_theme;
import '../models/track.dart';
import '../services/relationship_service.dart';
import '../constants/app_theme.dart';

/// 기분 → 테마 → 트랙의 관계형 플로우를 보여주는 위젯
/// 데이터베이스의 관계 테이블 구조를 UI에 시각적으로 반영
class MoodThemeFlow extends StatefulWidget {
  final Mood? initialMood;
  final Function(app_theme.Theme)? onThemeSelected;
  final Function(Track)? onTrackSelected;

  const MoodThemeFlow({
    super.key,
    this.initialMood,
    this.onThemeSelected,
    this.onTrackSelected,
  });

  @override
  State<MoodThemeFlow> createState() => _MoodThemeFlowState();
}

class _MoodThemeFlowState extends State<MoodThemeFlow> {
  final RelationshipService _relationshipService = RelationshipService();
  
  Mood? _selectedMood;
  List<app_theme.Theme> _relatedThemes = [];
  app_theme.Theme? _selectedTheme;
  List<Track> _themeTracks = [];
  bool _isLoadingThemes = false;
  bool _isLoadingTracks = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMood != null) {
      _selectMood(widget.initialMood!);
    }
  }

  Future<void> _selectMood(Mood mood) async {
    setState(() {
      _selectedMood = mood;
      _selectedTheme = null;
      _themeTracks = [];
      _isLoadingThemes = true;
    });

    try {
      final themes = await _relationshipService.getThemesByMood(mood.name);
      setState(() {
        _relatedThemes = themes;
        _isLoadingThemes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingThemes = false;
        _relatedThemes = [];
      });
      debugPrint('기분별 테마 로드 실패: $e');
    }
  }

  Future<void> _selectTheme(app_theme.Theme theme) async {
    setState(() {
      _selectedTheme = theme;
      _isLoadingTracks = true;
    });

    try {
      final tracks = await _relationshipService.getTracksByTheme(theme);
      setState(() {
        _themeTracks = tracks;
        _isLoadingTracks = false;
      });
      
      widget.onThemeSelected?.call(theme);
    } catch (e) {
      setState(() {
        _isLoadingTracks = false;
        _themeTracks = [];
      });
      debugPrint('테마별 트랙 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1단계: 선택된 기분 표시
        if (_selectedMood != null) ...[
          _buildSectionHeader('선택된 기분', '데이터베이스: moods 테이블'),
          _buildSelectedMoodCard(),
          const SizedBox(height: 16),
        ],

        // 2단계: 관련 테마들 (theme_moods 관계 테이블 기반)
        if (_selectedMood != null) ...[
          _buildSectionHeader('추천 테마', 'theme_moods 관계 테이블 조인'),
          _buildThemesSection(),
          const SizedBox(height: 16),
        ],

        // 3단계: 선택된 테마의 트랙들 (theme_tracks 관계 테이블 기반)
        if (_selectedTheme != null) ...[
          _buildSectionHeader('테마 트랙', 'theme_tracks 관계 테이블 조인'),
          _buildTracksSection(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String dbInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          dbInfo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSelectedMoodCard() {
    if (_selectedMood == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            _selectedMood!.emoji ?? '😊',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMood!.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: ${_selectedMood!.id} • 순서: ${_selectedMood!.displayOrder}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'DB 연결',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection() {
    if (_isLoadingThemes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_relatedThemes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('이 기분과 연결된 테마가 없습니다.'),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_relatedThemes.length}개 테마 • theme_moods 테이블에서 조회',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...(_relatedThemes.map((theme) => _buildThemeCard(theme))),
      ],
    );
  }

  Widget _buildThemeCard(app_theme.Theme theme) {
    final isSelected = _selectedTheme?.id == theme.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectTheme(theme),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.library_music,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      theme.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'ID: ${theme.id}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${theme.trackCount}곡',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTracksSection() {
    if (_isLoadingTracks) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_themeTracks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('이 테마에 포함된 트랙이 없습니다.'),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_themeTracks.length}개 트랙 • theme_tracks 테이블에서 조회 • display_order로 정렬',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...(_themeTracks.map((track) => _buildTrackCard(track))),
      ],
    );
  }

  Widget _buildTrackCard(Track track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onTrackSelected?.call(track),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: track.isAsmr ? Colors.purple.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  track.isAsmr ? Icons.headphones : Icons.music_note,
                  size: 16,
                  color: track.isAsmr ? Colors.purple.shade600 : Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'ID: ${track.id}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (track.bpm != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${track.bpm}BPM',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          track.category ?? 'N/A',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (track.effectKeywords.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
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
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/relationship_service.dart';
import '../../services/supabase_service.dart';
import '../../constants/app_theme.dart';
import '../../models/mood.dart';
import '../../models/theme.dart' as app_theme;
import '../../models/track.dart';

/// 데이터베이스 관계형 구조를 시각화하는 디버그 화면
/// 개발/테스트 목적으로 DB 관계 테이블들의 연결 상태를 확인
class DatabaseRelationsScreen extends StatefulWidget {
  const DatabaseRelationsScreen({super.key});

  @override
  State<DatabaseRelationsScreen> createState() => _DatabaseRelationsScreenState();
}

class _DatabaseRelationsScreenState extends State<DatabaseRelationsScreen> {
  final RelationshipService _relationshipService = RelationshipService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Mood> _moods = [];
  List<app_theme.Theme> _themes = [];
  List<Track> _tracks = [];
  Map<String, dynamic> _relationStats = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _supabaseService.getMoods(),
        _supabaseService.getThemes(), 
        _supabaseService.getTracks(),
        _relationshipService.getRelationshipStats(),
      ]);

      setState(() {
        _moods = results[0] as List<Mood>;
        _themes = results[1] as List<app_theme.Theme>;
        _tracks = results[2] as List<Track>;
        _relationStats = results[3] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터베이스 관계 구조'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('오류: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(),
                      const SizedBox(height: 16),
                      _buildRelationshipStats(),
                      const SizedBox(height: 16),
                      _buildEntityTables(),
                      const SizedBox(height: 16),
                      _buildRelationshipFlow(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '데이터베이스 개요',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'EverySleep 앱의 정규화된 관계형 데이터베이스 구조',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              '주요 테이블: moods, themes, tracks, keywords\n'
              '관계 테이블: theme_moods, theme_tracks, track_keywords\n'
              '사용자 테이블: user_mood_logs, user_play_logs, user_feedback',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '관계 통계',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('기분', '${_relationStats['moods'] ?? 0}', Icons.mood),
                _buildStatCard('테마', '${_relationStats['themes'] ?? 0}', Icons.library_music),
                _buildStatCard('트랙', '${_relationStats['tracks'] ?? 0}', Icons.music_note),
                _buildStatCard('키워드', '${_relationStats['keywords'] ?? 0}', Icons.tag),
                _buildStatCard('기분-테마 관계', '${_relationStats['theme_mood_relations'] ?? 0}', Icons.link),
                _buildStatCard('테마-트랙 관계', '${_relationStats['theme_track_relations'] ?? 0}', Icons.link),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityTables() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '엔티티 테이블',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEntityTable('기분 (moods)', _moods.map((m) => {
              'ID': m.id.toString(),
              '이름': m.name,
              '이모지': m.emoji ?? 'N/A',
              '순서': m.displayOrder.toString(),
            }).toList()),
            const SizedBox(height: 16),
            _buildEntityTable('테마 (themes)', _themes.map((t) => {
              'ID': t.id.toString(),
              '코드': t.code,
              '제목': t.title,
              '트랙수': t.trackCount.toString(),
            }).toList()),
            const SizedBox(height: 16),
            _buildEntityTable('트랙 (tracks - 일부)', _tracks.take(5).map((tr) => {
              'ID': tr.id.toString(),
              '코드': tr.code,
              '제목': tr.title.length > 15 ? '${tr.title.substring(0, 15)}...' : tr.title,
              'BPM': tr.bpm?.toString() ?? 'N/A',
              'ASMR': tr.isAsmr ? 'Yes' : 'No',
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityTable(String title, List<Map<String, String>> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final headers = data.first.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: Colors.grey.shade100,
                child: Row(
                  children: headers.map((header) => Expanded(
                    child: Text(
                      header,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ),
              // Rows
              ...data.map((row) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: headers.map((header) => Expanded(
                    child: Text(
                      row[header] ?? 'N/A',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipFlow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.device_hub, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '관계 플로우',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildFlowStep('1. 사용자가 기분 선택', 'moods 테이블', Icons.mood),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_downward, color: Colors.grey),
                  const SizedBox(height: 8),
                  _buildFlowStep('2. 기분과 연결된 테마 조회', 'theme_moods 관계 테이블 JOIN', Icons.link),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_downward, color: Colors.grey),
                  const SizedBox(height: 8),
                  _buildFlowStep('3. 테마의 트랙들 조회', 'theme_tracks 관계 테이블 JOIN', Icons.link),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_downward, color: Colors.grey),
                  const SizedBox(height: 8),
                  _buildFlowStep('4. 트랙의 키워드 정보', 'track_keywords 관계 테이블 JOIN', Icons.tag),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 플로우는 정규화된 데이터베이스 설계의 핵심 장점을 보여줍니다:\n'
                      '• 데이터 중복 없음\n'
                      '• 유연한 관계 설정\n'
                      '• 확장성과 유지보수성',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/track_repository_provider.dart';
import '../constants/app_theme.dart';
import '../models/nature_sound.dart';

class NatureSoundSelector extends StatefulWidget {
  const NatureSoundSelector({super.key});

  @override
  State<NatureSoundSelector> createState() => _NatureSoundSelectorState();
}

class _NatureSoundSelectorState extends State<NatureSoundSelector>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;
  
  List<NatureSound> _natureSounds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadNatureSounds();
  }
  
  /// 자연음 데이터 로드
  Future<void> _loadNatureSounds() async {
    try {
      final trackRepositoryProvider = context.read<TrackRepositoryProvider>();
      final sounds = await trackRepositoryProvider.getNatureSoundsSorted();
      
      if (mounted) {
        setState(() {
          _natureSounds = sounds;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _natureSounds = [];
          _isLoading = false;
          _error = '자연음 데이터를 불러올 수 없습니다: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final currentSound = audioProvider.currentNatureSound;

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 (항상 표시) - 드래그 제스처 적용
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleExpanded,
            onVerticalDragEnd: (details) {
              // 드래그 속도와 방향에 따른 확장/축소
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -200 && !_isExpanded) {
                  // 위로 드래그 시 확장
                  _toggleExpanded();
                } else if (details.primaryVelocity! > 200 && _isExpanded) {
                  // 아래로 드래그 시 축소
                  _toggleExpanded();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  // 핸들 바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _isExpanded ? AppTheme.secondaryColor.withValues(alpha: 0.6) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentSound != null 
                              ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            currentSound?.icon ?? Icons.music_note,
                            color: currentSound != null 
                                ? currentSound.color 
                                : Colors.grey.shade400,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSound != null ? currentSound.name : '자연음 추가하기',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: currentSound != null 
                                    ? AppTheme.textPrimaryColor 
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                            Text(
                              currentSound != null 
                                  ? '음악과 함께 재생 중' 
                                  : '편안한 배경음을 선택해보세요',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentSound != null)
                        Container(
                          margin: const EdgeInsets.only(right: AppTheme.spacingS),
                          child: Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                audioProvider.loadNatureSound(null);
                                // 이벤트 전파 방지 - 부모 GestureDetector로 전달되지 않음
                              },
                              // 드래그 제스처를 차단하여 부모로 전달되지 않도록 함
                              onVerticalDragEnd: (details) {
                                // 빈 핸들러로 제스처 소비
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '끄기',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 3.14159,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: AppTheme.textSecondaryColor,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 자연음 선택 영역 (확장 시에만 표시)
          ClipRect(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: AppTheme.spacingL,
                      right: AppTheme.spacingL,
                      bottom: AppTheme.spacingL,
                    ),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: AppTheme.spacingM),
                        _buildNatureSoundGrid(audioProvider, currentSound),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 자연음 그리드 빌드 (로딩/에러 상태 처리)
  Widget _buildNatureSoundGrid(dynamic audioProvider, dynamic currentSound) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '자연음 로딩 실패',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            ElevatedButton(
              onPressed: _loadNatureSounds,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    
    if (_natureSounds.isEmpty) {
      return const Center(
        child: Text(
          '자연음이 없습니다',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: AppTheme.spacingM,
      mainAxisSpacing: AppTheme.spacingM,
      childAspectRatio: 1,
      children: _natureSounds.map((sound) {
        final isSelected = currentSound?.idString == sound.code;
        
        return GestureDetector(
          onTap: () {
            if (isSelected) {
              audioProvider.loadNatureSound(null);
            } else {
              audioProvider.loadNatureSound(sound);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.secondaryColor.withValues(alpha: 0.15),
                        AppTheme.secondaryColor.withValues(alpha: 0.25),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.secondaryColor 
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sound.icon,
                  size: isSelected ? 48 : 44,
                  color: isSelected 
                      ? sound.color 
                      : sound.color.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 6),
                Text(
                  sound.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected 
                        ? AppTheme.secondaryColor 
                        : AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
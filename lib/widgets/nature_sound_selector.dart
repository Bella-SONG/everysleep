import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
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

  static final List<NatureSound> natureSounds = [
    NatureSound(
      id: 'rain',
      name: '빗소리',
      icon: '🌧️',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    ),
    NatureSound(
      id: 'ocean',
      name: '파도소리',
      icon: '🌊',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    ),
    NatureSound(
      id: 'forest',
      name: '숲속소리',
      icon: '🌲',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    ),
    NatureSound(
      id: 'birds',
      name: '새소리',
      icon: '🐦',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
    ),
    NatureSound(
      id: 'fire',
      name: '모닥불',
      icon: '🔥',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
    ),
    NatureSound(
      id: 'thunder',
      name: '천둥소리',
      icon: '⛈️',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
    ),
  ];

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
          // 헤더 (항상 표시)
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  // 핸들 바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: AppTheme.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          currentSound != null 
                              ? '${currentSound.icon} ${currentSound.name}' 
                              : '자연음 선택',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: currentSound != null 
                                ? AppTheme.secondaryColor 
                                : AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      if (currentSound != null)
                        Container(
                          margin: const EdgeInsets.only(right: AppTheme.spacingS),
                          child: TextButton(
                            onPressed: () {
                              audioProvider.loadNatureSound(null);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '끄기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
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
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: AppTheme.spacingM,
                          mainAxisSpacing: AppTheme.spacingM,
                          childAspectRatio: 1,
                          children: natureSounds.map((sound) {
                            final isSelected = currentSound?.id == sound.id;
                            
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
                                    Text(
                                      sound.icon,
                                      style: TextStyle(
                                        fontSize: isSelected ? 32 : 28,
                                      ),
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
                        ),
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
}
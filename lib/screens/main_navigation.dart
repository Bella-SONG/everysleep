import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/bottom_player.dart';
import 'home/home_screen.dart';
import 'music/recommended_music_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecommendedMusicScreen(),
    const ProfileScreen(),
  ];

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final hasCurrentTrack = audioProvider.currentTrack != null;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasCurrentTrack) const BottomPlayer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.home_outlined, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.home, size: 28),
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.graphic_eq_outlined, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.graphic_eq, size: 28),
                  ),
                  label: '추천음악',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.person_outline, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.person, size: 28),
                  ),
                  label: '내 정보',
                ),
              ],
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondaryColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedFontSize: 16,
              unselectedFontSize: 14,
              iconSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
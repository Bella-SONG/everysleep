import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/player/player_screen.dart';
import '../screens/music/theme_detail_screen.dart';
import '../screens/music/popular_tracks_screen.dart';

// 커스텀 페이드 전환 애니메이션
Page<T> fadeTransitionPage<T extends Object?>({
  required Widget child,
  required GoRouterState state,
  Duration duration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SplashScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const LoginScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const MainNavigation(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/player',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const PlayerScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/themes/:id',
      pageBuilder: (context, state) {
        final themeId = int.parse(state.pathParameters['id']!);
        return fadeTransitionPage(
          child: ThemeDetailScreen(themeId: themeId),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/popular-tracks',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const PopularTracksScreen(),
        state: state,
      ),
    ),
  ],
);
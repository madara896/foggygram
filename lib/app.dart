import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/splash/splash_screen.dart';
import 'package:foggygram/features/auth/vault_unlock_screen.dart';
import 'package:foggygram/features/auth/login_screen.dart';
import 'package:foggygram/features/home/home_screen.dart';

CustomTransitionPage<void> _buildFadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: child,
      );
    },
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/vault-unlock',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        key: state.pageKey,
        child: const VaultUnlockScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
  ],
);

class FoggygramApp extends StatelessWidget {
  const FoggygramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Foggygram',
      debugShowCheckedModeBanner: false,
      theme: FoggyTheme.darkTheme,
      darkTheme: FoggyTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}

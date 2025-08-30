import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/landing_screen.dart';
import 'screens/picker_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/result_screen.dart';
import 'screens/about_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/picker',
      name: 'picker',
      builder: (context, state) => const PickerScreen(),
    ),
    GoRoute(
      path: '/process',
      name: 'process',
      builder: (context, state) {
        final photoId = state.uri.queryParameters['photoId'];
        return ProcessingScreen(photoId: photoId);
      },
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) {
        final photoId = state.uri.queryParameters['photoId'];
        return ResultScreen(photoId: photoId);
      },
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri.path}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
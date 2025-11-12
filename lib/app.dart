import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/analysis_type.dart';
import 'models/analysis_mode.dart';
import 'pages/landing_page.dart';
import 'pages/analysis_loading_page.dart';
import 'pages/results_page.dart';
import 'pages/auth_page.dart';
import 'pages/profile_page.dart';
import 'pages/credits_page.dart';
import 'theme/app_theme.dart';

// Router configuration - defined outside the widget to prevent recreation
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/analyze',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          // Redirect to home if accessed without proper data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return const LandingPage();
        }
        return AnalysisLoadingPage(
          url: extra['url'] as String,
          analysisType: extra['type'] as AnalysisType,
          analysisMode: extra['mode'] as AnalysisMode,
        );
      },
    ),
    GoRoute(
      path: '/results/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ResultsPage(resultId: id);
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/credits',
      builder: (context, state) => const CreditsPage(),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VibeCheck',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

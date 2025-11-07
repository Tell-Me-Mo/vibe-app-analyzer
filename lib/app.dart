import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/analysis_type.dart';
import 'pages/landing_page.dart';
import 'pages/analysis_loading_page.dart';
import 'pages/results_page.dart';

class App extends StatelessWidget {
  App({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/analyze',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AnalysisLoadingPage(
            repositoryUrl: extra['url'] as String,
            analysisType: extra['type'] as AnalysisType,
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
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VibeCheck',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF60A5FA),           // Modern blue
          secondary: Color(0xFF34D399),          // Teal/Green
          surface: Color(0xFF0F172A),            // Deep slate
          surfaceContainerHighest: Color(0xFF1E293B),
          error: Color(0xFFF87171),
          onPrimary: Color(0xFF0F172A),
          onSecondary: Color(0xFF0F172A),
          onSurface: Color(0xFFF1F5F9),
          outline: Color(0xFF475569),
        ),
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF1F5F9),
            letterSpacing: -0.5,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF1F5F9),
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF1F5F9),
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFFF1F5F9),
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            color: Color(0xFFCBD5E1),
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

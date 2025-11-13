import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'widgets/loading_screen.dart';
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  // IMPORTANT: Configure URL strategy FIRST, before any async operations
  // This must run synchronously before WidgetsFlutterBinding.ensureInitialized()
  usePathUrlStrategy();

  // Now run async initialization
  _initializeApp();
}

Future<void> _initializeApp() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://de1d2da8fd4a90072b4c053e267d71e1@o4507007486394368.ingest.us.sentry.io/4510357912813568';
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;

      // Filter out the benign go_router initialization error
      options.beforeSend = (event, hint) {
        // Ignore the "Could not navigate to initial route" error - it's a false positive
        // that occurs during go_router initialization in debug mode on web
        if (event.message?.formatted?.contains('Could not navigate to initial route') ?? false) {
          return null; // Don't send to Sentry
        }
        return event;
      };
    },
    appRunner: () async {
      // Initialize Flutter bindings inside Sentry's zone
      WidgetsFlutterBinding.ensureInitialized();

      // Show loading screen immediately
      runApp(const LoadingScreen());

      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase Analytics
      FirebaseAnalytics.instance;

      // Log app open event
      await AnalyticsService().logAppOpen();

      // Initialize Supabase
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      );

      // Initialize storage
      await StorageService().initialize();

      // Preload Google Fonts to prevent FOUT (Flash of Unstyled Text)
      await _preloadFonts();

      // Ensure user is authenticated (anonymously if not signed in)
      try {
        await AuthService().ensureAuthenticated();
      } catch (e) {
        // If anonymous auth fails, continue anyway - user can still sign up/in manually
        debugPrint('Failed to initialize anonymous auth: $e');
      }

      // Launch the main app after initialization is complete
      runApp(const ProviderScope(
        child: VibeCheckApp(),
      ));
    },
  );
}

/// Preload Google Fonts to prevent flash of unstyled text
Future<void> _preloadFonts() async {
  try {
    // Preload Inter font family with all weights used in the app
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(fontWeight: FontWeight.w400),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
      GoogleFonts.inter(fontWeight: FontWeight.w700),
      GoogleFonts.inter(fontWeight: FontWeight.w800),
      GoogleFonts.inter(fontWeight: FontWeight.w900),
      // Preload JetBrains Mono for code snippets
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w400),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w500),
    ]);
  } catch (e) {
    debugPrint('Failed to preload fonts: $e');
    // Continue anyway - fonts will load normally
  }
}

class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App();
  }
}

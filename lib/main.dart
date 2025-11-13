import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show loading screen immediately
  runApp(const LoadingScreen());

  // Load environment variables
  await dotenv.load(fileName: ".env");

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
  runApp(
    const ProviderScope(
      child: VibeCheckApp(),
    ),
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

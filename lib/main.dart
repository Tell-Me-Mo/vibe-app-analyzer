import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize storage
  await StorageService().initialize();

  // Ensure user is authenticated (anonymously if not signed in)
  try {
    await AuthService().ensureAuthenticated();
  } catch (e) {
    // If anonymous auth fails, continue anyway - user can still sign up/in manually
    debugPrint('Failed to initialize anonymous auth: $e');
  }

  runApp(
    const ProviderScope(
      child: VibeCheckApp(),
    ),
  );
}

class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App();
  }
}

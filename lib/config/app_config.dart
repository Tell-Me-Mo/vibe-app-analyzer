import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // OpenAI Model (used in validation methods)
  static const String openaiModel = 'gpt-4o-mini';

  // App Configuration
  static const int maxTokensForAnalysis = 50000;
  static const int analysisTimeoutSeconds = 60;
  static const int maxHistoryItems = 10;

  // Storage Keys
  static const String sessionIdKey = 'session_id';
  static const String historyBoxName = 'analysis_history';
}

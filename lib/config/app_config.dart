import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // OpenAI Configuration
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String openaiModel = 'gpt-4o-mini';
  static const String openaiApiUrl = 'https://api.openai.com/v1/chat/completions';

  // GitHub Configuration
  static const String githubApiUrl = 'https://api.github.com';
  static String get githubToken => dotenv.env['GITHUB_TOKEN'] ?? '';

  // App Configuration
  static const int maxTokensForAnalysis = 50000;
  static const int analysisTimeoutSeconds = 60;
  static const int maxHistoryItems = 10;

  // Storage Keys
  static const String sessionIdKey = 'session_id';
  static const String historyBoxName = 'analysis_history';
}

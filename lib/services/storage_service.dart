import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/analysis_result.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    await Hive.initFlutter();

    // For now, we'll use a simple box without type adapters
    // and serialize/deserialize manually
    _prefs = await SharedPreferences.getInstance();
  }

  // Session Management
  Future<String> getOrCreateSessionId() async {
    String? sessionId = _prefs.getString(AppConfig.sessionIdKey);
    if (sessionId == null) {
      sessionId = const Uuid().v4();
      await _prefs.setString(AppConfig.sessionIdKey, sessionId);
    }
    return sessionId;
  }

  // History Management using SharedPreferences (simplified for MVP)
  Future<void> saveAnalysis(AnalysisResult result) async {
    final history = getHistory();
    history.insert(0, result);

    // Keep only the latest items
    if (history.length > AppConfig.maxHistoryItems) {
      history.removeRange(AppConfig.maxHistoryItems, history.length);
    }

    // Save as JSON string list
    final jsonList = history.map((r) => r.toJson()).toList();
    final jsonString = jsonList.map((json) => jsonEncode(json)).toList();
    await _prefs.setStringList('history', jsonString);
  }

  List<AnalysisResult> getHistory() {
    final jsonStrings = _prefs.getStringList('history') ?? [];
    return jsonStrings.map((str) {
      final json = jsonDecode(str) as Map<String, dynamic>;
      return AnalysisResult.fromJson(json);
    }).toList();
  }

  AnalysisResult? getAnalysisById(String id) {
    final history = getHistory();
    return history.where((r) => r.id == id).firstOrNull;
  }

  Future<void> clearHistory() async {
    await _prefs.remove('history');
  }
}

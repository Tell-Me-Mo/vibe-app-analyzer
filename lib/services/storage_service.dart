import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:uuid/uuid.dart';
import '../models/analysis_result.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  encrypt.Encrypter? _encrypter;
  encrypt.IV? _iv;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Initialize encryption for sensitive data
    await _initializeEncryption();
  }

  /// Initialize encryption key for analysis data
  Future<void> _initializeEncryption() async {
    try {
      // Try to retrieve existing encryption key from SharedPreferences
      String? keyString = _prefs.getString('encryption_key');
      String? ivString = _prefs.getString('encryption_iv');

      if (keyString == null || ivString == null) {
        // Generate new encryption key and IV
        final key = encrypt.Key.fromSecureRandom(32); // 256-bit key
        final iv = encrypt.IV.fromSecureRandom(16); // 128-bit IV

        // Store in SharedPreferences
        await _prefs.setString('encryption_key', base64Encode(key.bytes));
        await _prefs.setString('encryption_iv', base64Encode(iv.bytes));

        _encrypter = encrypt.Encrypter(encrypt.AES(key));
        _iv = iv;
      } else {
        // Use existing key
        final keyBytes = base64Decode(keyString);
        final ivBytes = base64Decode(ivString);

        final key = encrypt.Key(Uint8List.fromList(keyBytes));
        final iv = encrypt.IV(Uint8List.fromList(ivBytes));

        _encrypter = encrypt.Encrypter(encrypt.AES(key));
        _iv = iv;
      }
    } catch (e) {
      // Fallback: encryption initialization failed, continue without encryption
      // This can happen on web platform where secure storage might not be available
      _encrypter = null;
      _iv = null;
    }
  }

  /// Encrypt sensitive data
  String _encrypt(String plainText) {
    if (_encrypter == null || _iv == null) {
      // Encryption not available, return plaintext (web fallback)
      return plainText;
    }

    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      // Encryption failed, return plaintext
      return plainText;
    }
  }

  /// Decrypt sensitive data
  String _decrypt(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      // Encryption not available, assume plaintext
      return encryptedText;
    }

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter!.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Decryption failed, try returning as-is (might be legacy plaintext)
      return encryptedText;
    }
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

  // History Management with encryption for sensitive data
  Future<void> saveAnalysis(AnalysisResult result) async {
    print('💾 [STORAGE] saveAnalysis called for ID: ${result.id}');
    final history = getHistory();
    print('💾 [STORAGE] Current history size: ${history.length}');
    history.insert(0, result);
    print('💾 [STORAGE] Inserted result, new size: ${history.length}');

    // Keep only the latest items
    if (history.length > AppConfig.maxHistoryItems) {
      history.removeRange(AppConfig.maxHistoryItems, history.length);
    }

    // Apply TTL: Remove analyses older than 30 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    history.removeWhere((r) => r.timestamp.isBefore(cutoffDate));

    try {
      // Serialize to JSON
      final jsonList = history.map((r) => r.toJson()).toList();
      final jsonStrings = jsonList.map((json) => jsonEncode(json)).toList();

      // Encrypt each analysis result
      final encryptedStrings = jsonStrings.map((str) => _encrypt(str)).toList();

      // Save encrypted data
      print('💾 [STORAGE] Writing ${encryptedStrings.length} items to SharedPreferences');
      await _prefs.setStringList('history', encryptedStrings);
      print('💾 [STORAGE] ✅ Successfully saved to SharedPreferences');
    } catch (e) {
      print('💾 [STORAGE] ❌ Error saving: $e');
      throw Exception('Failed to save analysis history: $e');
    }
  }

  List<AnalysisResult> getHistory() {
    try {
      final encryptedStrings = _prefs.getStringList('history') ?? [];

      return encryptedStrings.map((encryptedStr) {
        // Decrypt the data
        final decryptedStr = _decrypt(encryptedStr);

        // Parse JSON
        final json = jsonDecode(decryptedStr) as Map<String, dynamic>;
        return AnalysisResult.fromJson(json);
      }).toList();
    } catch (e) {
      // If decryption/parsing fails, return empty list
      // This can happen after key rotation or migration
      return [];
    }
  }

  AnalysisResult? getAnalysisById(String id) {
    final history = getHistory();
    return history.where((r) => r.id == id).firstOrNull;
  }

  Future<void> updateAnalysis(AnalysisResult updatedResult) async {
    final history = getHistory();
    final index = history.indexWhere((r) => r.id == updatedResult.id);

    if (index != -1) {
      history[index] = updatedResult;

      try {
        // Serialize to JSON
        final jsonList = history.map((r) => r.toJson()).toList();
        final jsonStrings = jsonList.map((json) => jsonEncode(json)).toList();

        // Encrypt each analysis result
        final encryptedStrings = jsonStrings.map((str) => _encrypt(str)).toList();

        // Save encrypted data
        await _prefs.setStringList('history', encryptedStrings);
      } catch (e) {
        throw Exception('Failed to update analysis: $e');
      }
    }
  }

  Future<void> clearHistory() async {
    await _prefs.remove('history');
  }
}

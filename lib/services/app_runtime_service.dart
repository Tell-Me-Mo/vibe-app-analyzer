import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/runtime_analysis_data.dart';
import '../config/app_config.dart';

/// Service for analyzing live deployed applications via Supabase Edge Function
class AppRuntimeService {
  final Dio _dio;
  final SupabaseClient _supabase;

  AppRuntimeService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          validateStatus: (status) => status != null && status < 600,
        )),
        _supabase = Supabase.instance.client;

  /// Fetches and analyzes a live application via Edge Function
  /// This avoids CORS issues by proxying the request through Supabase
  Future<RuntimeAnalysisData> analyzeApp(String url) async {
    try {
      // Get the Supabase Edge Function URL
      final supabaseUrl = AppConfig.supabaseUrl;
      final functionUrl = '$supabaseUrl/functions/v1/runtime-analyze';

      // Get the current session token
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please sign in.');
      }

      // Call the Edge Function to fetch and analyze the application
      final response = await _dio.post(
        functionUrl,
        data: {
          'url': url,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': AppConfig.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        final errorData = response.data;
        if (errorData is Map && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        }
        throw Exception('Failed to analyze application: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;

      // Parse the response into RuntimeAnalysisData
      return RuntimeAnalysisData.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please sign in and try again.');
      } else if (e.response?.statusCode == 502) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('details')) {
          throw Exception(errorData['details']);
        }
        throw Exception(
          'Could not reach $url. Please check if the URL is correct and accessible.',
        );
      } else if (e.response?.data is Map) {
        final errorData = e.response!.data as Map;
        if (errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        }
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout: Could not reach the analysis service. Please try again.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Response timeout: The analysis took too long. The application may be slow or unresponsive.',
        );
      }

      throw Exception(
        'Failed to analyze application: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error analyzing application: $e');
    }
  }

  // Note: All detection and analysis logic is now handled server-side
  // in the runtime-analyze Edge Function to avoid CORS issues
}

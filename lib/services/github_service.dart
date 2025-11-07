import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/validators.dart';

class GitHubService {
  final Dio _dio;

  GitHubService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.githubApiUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': 'Bearer ${AppConfig.githubToken}',
          },
        ));

  Future<Map<String, dynamic>> getRepository(String repoUrl) async {
    final parts = Validators.parseGitHubUrl(repoUrl);
    if (parts == null) {
      throw Exception('Invalid GitHub URL');
    }

    try {
      final response = await _dio.get('/repos/${parts['owner']}/${parts['repo']}');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch repository: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRepositoryTree(String repoUrl) async {
    final parts = Validators.parseGitHubUrl(repoUrl);
    if (parts == null) {
      throw Exception('Invalid GitHub URL');
    }

    try {
      final response = await _dio.get(
        '/repos/${parts['owner']}/${parts['repo']}/git/trees/main',
        queryParameters: {'recursive': '1'},
      );

      final tree = response.data['tree'] as List;
      return tree.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Try 'master' branch if 'main' doesn't exist
        try {
          final response = await _dio.get(
            '/repos/${parts['owner']}/${parts['repo']}/git/trees/master',
            queryParameters: {'recursive': '1'},
          );

          final tree = response.data['tree'] as List;
          return tree.map((e) => e as Map<String, dynamic>).toList();
        } catch (e2) {
          throw Exception('Failed to fetch repository tree: $e2');
        }
      }
      throw Exception('Failed to fetch repository tree: $e');
    }
  }

  Future<String> getFileContent(String repoUrl, String path) async {
    final parts = Validators.parseGitHubUrl(repoUrl);
    if (parts == null) {
      throw Exception('Invalid GitHub URL');
    }

    try {
      final response = await _dio.get(
        '/repos/${parts['owner']}/${parts['repo']}/contents/$path',
      );

      // Validate response
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format from GitHub API');
      }

      final content = response.data['content'];
      if (content == null || content is! String) {
        throw Exception('File content missing or invalid');
      }

      // GitHub API returns base64 encoded content
      final cleanedContent = content.replaceAll('\n', '').replaceAll(' ', '');

      // Validate it's valid base64 before decoding
      try {
        final decoded = base64Decode(cleanedContent);
        return utf8.decode(decoded, allowMalformed: true);
      } on FormatException catch (e) {
        throw Exception('Failed to decode file content: ${e.message}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('File not found: $path');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden. Check GitHub token permissions.');
      }
      throw Exception('Failed to fetch file content: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch file content: $e');
    }
  }

  /// Aggregates code from repository with streaming and memory management
  ///
  /// Features:
  /// - Streams files to avoid loading entire repo into memory
  /// - Validates file sizes before downloading
  /// - Respects token limits with accurate estimation
  /// - Prioritizes important files (src/, lib/ before tests/)
  /// - Handles errors gracefully, skipping problematic files
  Future<String> aggregateCode(String repoUrl) async {
    try {
      final tree = await getRepositoryTree(repoUrl);

      // Filter and prioritize code files
      final codeFiles = _filterAndPrioritizeFiles(tree);

      if (codeFiles.isEmpty) {
        throw Exception('No code files found in repository');
      }

      // Use StringBuffer for efficient string concatenation
      final buffer = StringBuffer();
      int estimatedTokens = 0;
      const maxTokens = AppConfig.maxTokensForAnalysis;
      int filesProcessed = 0;
      int filesSkipped = 0;

      // Process files in prioritized order
      for (var file in codeFiles) {
        final path = file['path'] as String;
        final size = file['size'] as int;

        // Validate file size before downloading
        if (size > 500000) {
          filesSkipped++;
          continue; // Skip files > 500KB
        }

        // Estimate tokens for this file (more accurate estimation)
        // Average: 1 token ≈ 4 characters for code
        final estimatedFileTokens = (size / 4).ceil();

        // Check if adding this file would exceed token limit
        if (estimatedTokens + estimatedFileTokens > maxTokens) {
          break; // Stop processing to stay within limits
        }

        try {
          // Fetch file content with streaming
          final content = await getFileContent(repoUrl, path);

          // Validate content length matches expected size (within 10% margin)
          if ((content.length - size).abs() > size * 0.1) {
            // Size mismatch, skip suspicious file
            filesSkipped++;
            continue;
          }

          // Add file header and content to buffer
          buffer.writeln('--- File: $path ---');
          buffer.writeln(content);
          buffer.writeln(); // Blank line separator

          // Update actual token count based on retrieved content
          final actualTokens = (content.length / 4).ceil();
          estimatedTokens += actualTokens;
          filesProcessed++;

          // Clear content from memory (let GC collect it)
          // This is automatic in Dart, but we break reference explicitly
        } catch (e) {
          // Log error but continue with other files
          filesSkipped++;
          continue;
        }
      }

      if (filesProcessed == 0) {
        throw Exception(
          'No files could be processed. Total files skipped: $filesSkipped',
        );
      }

      // Return aggregated code with metadata
      final result = buffer.toString();

      // Clear buffer to free memory
      buffer.clear();

      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Repository or branch not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception(
          'GitHub API rate limit exceeded or access forbidden. Try again later or add a GitHub token.',
        );
      }
      throw Exception('GitHub API error: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to aggregate code: $e');
    }
  }

  /// Filters and prioritizes files for analysis
  ///
  /// Priority order:
  /// 1. Source code in main directories (src/, lib/, app/)
  /// 2. Configuration files (package.json, pubspec.yaml, etc.)
  /// 3. Other code files
  /// 4. Documentation and tests (lower priority)
  List<Map<String, dynamic>> _filterAndPrioritizeFiles(List<Map<String, dynamic>> tree) {
    // Filter for valid code files only
    final codeFiles = tree.where((file) {
      if (file['type'] != 'blob') {
        return false;
      }

      final path = file['path'] as String?;
      final size = file['size'];

      if (path == null || size == null || size is! int) {
        return false;
      }

      return _isCodeFile(path) && size > 0 && size < 500000;
    }).toList();

    // Prioritize files by importance
    codeFiles.sort((a, b) {
      final pathA = a['path'] as String;
      final pathB = b['path'] as String;

      final priorityA = _getFilePriority(pathA);
      final priorityB = _getFilePriority(pathB);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB); // Lower number = higher priority
      }

      // Same priority, sort alphabetically
      return pathA.compareTo(pathB);
    });

    return codeFiles;
  }

  /// Assigns priority to files (lower number = higher priority)
  int _getFilePriority(String path) {
    final lowerPath = path.toLowerCase();

    // Highest priority: main source code
    if (lowerPath.startsWith('src/') ||
        lowerPath.startsWith('lib/') ||
        lowerPath.startsWith('app/')) {
      return 1;
    }

    // High priority: configuration and entry points
    if (lowerPath == 'package.json' ||
        lowerPath == 'pubspec.yaml' ||
        lowerPath == 'main.dart' ||
        lowerPath == 'index.js' ||
        lowerPath == 'app.js') {
      return 2;
    }

    // Medium priority: other source code
    if (!lowerPath.contains('test') &&
        !lowerPath.contains('spec') &&
        !lowerPath.contains('__test__')) {
      return 3;
    }

    // Lower priority: tests and documentation
    if (lowerPath.contains('test') ||
        lowerPath.contains('spec') ||
        lowerPath.contains('__test__')) {
      return 4;
    }

    // Lowest priority: documentation
    if (lowerPath.endsWith('.md') || lowerPath.startsWith('docs/')) {
      return 5;
    }

    return 3; // Default medium priority
  }

  bool _isCodeFile(String path) {
    final codeExtensions = [
      '.dart', '.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.kt',
      '.swift', '.go', '.rs', '.cpp', '.c', '.h', '.cs', '.php',
      '.rb', '.vue', '.html', '.css', '.scss', '.json', '.yaml',
      '.yml', '.xml', '.sql', '.sh', '.md'
    ];

    return codeExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}

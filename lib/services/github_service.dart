import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/validators.dart';

class GitHubService {
  final Dio _dio;

  GitHubService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.githubApiUrl,
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

      // GitHub API returns base64 encoded content
      final content = response.data['content'] as String;
      return Uri.decodeFull(content.replaceAll('\n', ''));
    } catch (e) {
      throw Exception('Failed to fetch file content: $e');
    }
  }

  Future<String> aggregateCode(String repoUrl) async {
    try {
      final tree = await getRepositoryTree(repoUrl);

      // Filter for code files (exclude images, videos, etc.)
      final codeFiles = tree.where((file) {
        final path = file['path'] as String;
        return file['type'] == 'blob' &&
            _isCodeFile(path) &&
            file['size'] < 500000; // Skip files > 500KB
      }).toList();

      final buffer = StringBuffer();
      int estimatedTokens = 0;
      const maxTokens = AppConfig.maxTokensForAnalysis;

      for (var file in codeFiles) {
        final path = file['path'] as String;

        try {
          final content = await getFileContent(repoUrl, path);
          final fileTokens = (content.length / 4).round(); // Rough estimate

          if (estimatedTokens + fileTokens > maxTokens) {
            break; // Stop if we exceed token limit
          }

          buffer.writeln('--- $path ---');
          buffer.writeln(content);
          buffer.writeln();

          estimatedTokens += fileTokens;
        } catch (e) {
          // Skip files we can't read
          continue;
        }
      }

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to aggregate code: $e');
    }
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

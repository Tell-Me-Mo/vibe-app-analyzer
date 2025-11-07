class Validators {
  /// Validates a GitHub repository URL with strict rules
  ///
  /// Valid formats:
  /// - https://github.com/owner/repo
  /// - https://www.github.com/owner/repo
  /// - http://github.com/owner/repo (upgraded to HTTPS)
  ///
  /// Rules:
  /// - URL length must be between 20 and 2048 characters
  /// - Owner name: 1-39 alphanumeric chars or hyphens, cannot start with hyphen
  /// - Repo name: 1-100 alphanumeric chars, dots, hyphens, underscores
  /// - No path traversal patterns
  /// - Optional trailing slash
  /// - Optional .git suffix
  static bool isValidGitHubUrl(String url) {
    final trimmedUrl = url.trim();

    // Check URL length bounds
    if (trimmedUrl.length < 20 || trimmedUrl.length > 2048) {
      return false;
    }

    // Strict GitHub URL regex
    // Owner: [a-zA-Z0-9][-a-zA-Z0-9]{0,38} (1-39 chars, can't start with hyphen)
    // Repo: [a-zA-Z0-9._-]{1,100}
    final regex = RegExp(
      r'^https?:\/\/(www\.)?github\.com\/[a-zA-Z0-9][-a-zA-Z0-9]{0,38}\/[a-zA-Z0-9._-]{1,100}(\.git)?\/?$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(trimmedUrl)) {
      return false;
    }

    // Additional validation: parse as URI
    try {
      final uri = Uri.parse(trimmedUrl);

      // Validate scheme
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      // Validate host
      if (uri.host != 'github.com' && uri.host != 'www.github.com') {
        return false;
      }

      // Validate path segments
      final segments = uri.pathSegments;
      if (segments.length < 2) {
        return false;
      }

      // Check for path traversal patterns
      if (trimmedUrl.contains('..') || trimmedUrl.contains('//')) {
        return false;
      }

      // Validate owner and repo names
      final owner = segments[0];
      final repo = segments[1].replaceAll('.git', '');

      // Owner validation: 1-39 chars, alphanumeric or hyphen, can't start with hyphen
      if (owner.isEmpty || owner.length > 39 || owner.startsWith('-')) {
        return false;
      }

      // Repo validation: 1-100 chars
      if (repo.isEmpty || repo.length > 100) {
        return false;
      }

      // Check for multiple consecutive hyphens or underscores (usually invalid)
      if (owner.contains('--') || repo.contains('__')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parses a validated GitHub URL into owner and repo components
  ///
  /// Returns null if URL is invalid
  static Map<String, String>? parseGitHubUrl(String url) {
    if (!isValidGitHubUrl(url)) {
      return null;
    }

    try {
      final uri = Uri.parse(url.trim());
      final segments = uri.pathSegments;

      if (segments.length >= 2) {
        final owner = segments[0];
        final repo = segments[1].replaceAll('.git', '');

        return {
          'owner': owner,
          'repo': repo,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sanitizes a GitHub URL for safe usage
  ///
  /// - Removes trailing slashes
  /// - Upgrades HTTP to HTTPS
  /// - Removes www subdomain for consistency
  /// - Returns null if URL is invalid
  static String? sanitizeGitHubUrl(String url) {
    if (!isValidGitHubUrl(url)) {
      return null;
    }

    try {
      final uri = Uri.parse(url.trim());
      final segments = uri.pathSegments;

      if (segments.length < 2) {
        return null;
      }

      final owner = segments[0];
      final repo = segments[1].replaceAll('.git', '');

      // Return canonical URL format
      return 'https://github.com/$owner/$repo';
    } catch (e) {
      return null;
    }
  }
}

import '../models/analysis_mode.dart';

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

  /// Validates a live application URL
  ///
  /// Valid formats:
  /// - https://example.com
  /// - https://www.example.com
  /// - http://example.com (will be upgraded to HTTPS)
  /// - https://subdomain.example.com
  /// - https://example.com/path (with paths)
  ///
  /// Rules:
  /// - Must have http or https scheme
  /// - Must not be a GitHub URL
  /// - Must have a valid host
  /// - URL length must be between 10 and 2048 characters
  /// - No path traversal patterns
  static bool isValidAppUrl(String url) {
    final trimmedUrl = url.trim();

    // Check URL length bounds
    if (trimmedUrl.length < 10 || trimmedUrl.length > 2048) {
      return false;
    }

    try {
      final uri = Uri.parse(trimmedUrl);

      // Must have http or https scheme
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      // Must have a valid host
      if (uri.host.isEmpty) {
        return false;
      }

      // Must not be a GitHub repository URL
      if (uri.host == 'github.com' || uri.host == 'www.github.com') {
        // Allow GitHub Pages (user.github.io) but not repos
        if (!uri.host.endsWith('.github.io')) {
          return false;
        }
      }

      // Check for path traversal patterns
      if (trimmedUrl.contains('..')) {
        return false;
      }

      // Validate host has valid domain structure
      if (!_isValidDomain(uri.host)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates if a domain has valid structure
  static bool _isValidDomain(String domain) {
    // Remove port if present
    final domainWithoutPort = domain.split(':')[0];

    // Check for localhost and IP addresses (valid for testing)
    if (domainWithoutPort == 'localhost' ||
        domainWithoutPort == '127.0.0.1' ||
        _isValidIPAddress(domainWithoutPort)) {
      return true;
    }

    // Domain must have at least one dot for TLD
    if (!domainWithoutPort.contains('.')) {
      return false;
    }

    // Basic domain validation regex
    final domainRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    return domainRegex.hasMatch(domainWithoutPort);
  }

  /// Checks if string is a valid IP address
  static bool _isValidIPAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return false;
      }
    }
    return true;
  }

  /// Detects the type of URL and returns the appropriate analysis mode
  ///
  /// Returns null if URL is invalid
  static AnalysisMode? detectUrlType(String url) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      return null;
    }

    if (isValidGitHubUrl(trimmedUrl)) {
      return AnalysisMode.staticCode;
    } else if (isValidAppUrl(trimmedUrl)) {
      return AnalysisMode.runtime;
    }

    return null;
  }

  /// Sanitizes an app URL for safe usage
  ///
  /// - Removes trailing slashes
  /// - Upgrades HTTP to HTTPS
  /// - Normalizes the URL format
  /// - Returns null if URL is invalid
  static String? sanitizeAppUrl(String url) {
    if (!isValidAppUrl(url)) {
      return null;
    }

    try {
      final uri = Uri.parse(url.trim());

      // Upgrade to HTTPS (except localhost)
      final scheme = uri.host == 'localhost' || uri.host == '127.0.0.1'
          ? uri.scheme
          : 'https';

      // Build canonical URL
      var canonicalUrl = '$scheme://${uri.host}';

      if (uri.hasPort && uri.port != 80 && uri.port != 443) {
        canonicalUrl += ':${uri.port}';
      }

      if (uri.path.isNotEmpty && uri.path != '/') {
        canonicalUrl += uri.path.endsWith('/')
            ? uri.path.substring(0, uri.path.length - 1)
            : uri.path;
      }

      return canonicalUrl;
    } catch (e) {
      return null;
    }
  }

  /// Extracts a display name from a URL
  ///
  /// For GitHub URLs: returns "owner/repo"
  /// For app URLs: returns the domain name
  static String getDisplayName(String url, AnalysisMode mode) {
    if (mode == AnalysisMode.staticCode) {
      final parsed = parseGitHubUrl(url);
      if (parsed != null) {
        return '${parsed['owner']}/${parsed['repo']}';
      }
    } else {
      try {
        final uri = Uri.parse(url.trim());
        return uri.host;
      } catch (e) {
        // Fallback
      }
    }

    // Fallback: return sanitized URL or original
    return url.trim();
  }
}

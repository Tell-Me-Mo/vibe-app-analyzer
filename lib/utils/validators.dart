class Validators {
  static bool isValidGitHubUrl(String url) {
    final regex = RegExp(
      r'^https?:\/\/(www\.)?github\.com\/[\w-]+\/[\w.-]+\/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url.trim());
  }

  static Map<String, String>? parseGitHubUrl(String url) {
    if (!isValidGitHubUrl(url)) {
      return null;
    }

    final uri = Uri.parse(url.trim());
    final segments = uri.pathSegments;

    if (segments.length >= 2) {
      return {
        'owner': segments[0],
        'repo': segments[1].replaceAll('.git', ''),
      };
    }

    return null;
  }
}

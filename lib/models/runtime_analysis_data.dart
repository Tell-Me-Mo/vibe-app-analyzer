/// Data collected from analyzing a live deployed application
class RuntimeAnalysisData {
  /// The URL of the analyzed application
  final String url;

  /// HTML content of the page
  final String html;

  /// HTTP response headers
  final Map<String, List<String>> headers;

  /// HTTP status code
  final int statusCode;

  /// Time to first byte in milliseconds
  final int ttfb;

  /// Total page load time in milliseconds
  final int pageLoadTime;

  /// Detected monitoring tools
  final DetectedTools detectedTools;

  /// Performance metrics
  final PerformanceMetrics performanceMetrics;

  /// Security configuration
  final SecurityConfig securityConfig;

  const RuntimeAnalysisData({
    required this.url,
    required this.html,
    required this.headers,
    required this.statusCode,
    required this.ttfb,
    required this.pageLoadTime,
    required this.detectedTools,
    required this.performanceMetrics,
    required this.securityConfig,
  });

  /// Converts to a formatted string for AI analysis
  String toAnalysisPrompt() {
    final buffer = StringBuffer();

    buffer.writeln('APP URL: $url');
    buffer.writeln();

    buffer.writeln('PERFORMANCE METRICS:');
    buffer.writeln('- Page Load Time: ${pageLoadTime}ms');
    buffer.writeln('- Time to First Byte: ${ttfb}ms');
    buffer.writeln('- Response Status: $statusCode');
    buffer.writeln();

    buffer.writeln('DETECTED MONITORING TOOLS:');
    buffer.writeln(detectedTools.toPromptString());
    buffer.writeln();

    buffer.writeln('SECURITY CONFIGURATION:');
    buffer.writeln(securityConfig.toPromptString());
    buffer.writeln();

    buffer.writeln('HTTP HEADERS:');
    headers.forEach((key, values) {
      buffer.writeln('$key: ${values.join(', ')}');
    });
    buffer.writeln();

    buffer.writeln('PAGE CONTENT (HTML):');
    // Truncate HTML if too long (max 50k chars)
    final truncatedHtml = html.length > 50000
        ? '${html.substring(0, 50000)}\n... [truncated]'
        : html;
    buffer.writeln(truncatedHtml);

    return buffer.toString();
  }
}

/// Detected monitoring and analytics tools
class DetectedTools {
  // Analytics
  final bool hasGoogleAnalytics;
  final bool hasMixpanel;
  final bool hasSegment;
  final bool hasAmplitude;
  final bool hasPostHog;
  final bool hasPlausible;

  // Error Tracking
  final bool hasSentry;
  final bool hasBugsnag;
  final bool hasRollbar;
  final bool hasLogRocket;

  // Session Replay
  final bool hasHotjar;
  final bool hasFullStory;

  // Performance Monitoring (APM)
  final bool hasNewRelic;
  final bool hasDatadog;
  final bool hasAppDynamics;

  // Other
  final bool hasMetaPixel;
  final bool hasLinkedInTag;

  const DetectedTools({
    this.hasGoogleAnalytics = false,
    this.hasMixpanel = false,
    this.hasSegment = false,
    this.hasAmplitude = false,
    this.hasPostHog = false,
    this.hasPlausible = false,
    this.hasSentry = false,
    this.hasBugsnag = false,
    this.hasRollbar = false,
    this.hasLogRocket = false,
    this.hasHotjar = false,
    this.hasFullStory = false,
    this.hasNewRelic = false,
    this.hasDatadog = false,
    this.hasAppDynamics = false,
    this.hasMetaPixel = false,
    this.hasLinkedInTag = false,
  });

  String toPromptString() {
    final buffer = StringBuffer();

    buffer.writeln('Analytics:');
    buffer.writeln('  ${hasGoogleAnalytics ? '✓' : '✗'} Google Analytics');
    buffer.writeln('  ${hasMixpanel ? '✓' : '✗'} Mixpanel');
    buffer.writeln('  ${hasSegment ? '✓' : '✗'} Segment');
    buffer.writeln('  ${hasAmplitude ? '✓' : '✗'} Amplitude');
    buffer.writeln('  ${hasPostHog ? '✓' : '✗'} PostHog');
    buffer.writeln('  ${hasPlausible ? '✓' : '✗'} Plausible');

    buffer.writeln('Error Tracking:');
    buffer.writeln('  ${hasSentry ? '✓' : '✗'} Sentry');
    buffer.writeln('  ${hasBugsnag ? '✓' : '✗'} Bugsnag');
    buffer.writeln('  ${hasRollbar ? '✓' : '✗'} Rollbar');
    buffer.writeln('  ${hasLogRocket ? '✓' : '✗'} LogRocket');

    buffer.writeln('Session Replay:');
    buffer.writeln('  ${hasHotjar ? '✓' : '✗'} Hotjar');
    buffer.writeln('  ${hasFullStory ? '✓' : '✗'} FullStory');

    buffer.writeln('Performance Monitoring (APM):');
    buffer.writeln('  ${hasNewRelic ? '✓' : '✗'} New Relic');
    buffer.writeln('  ${hasDatadog ? '✓' : '✗'} Datadog');
    buffer.writeln('  ${hasAppDynamics ? '✓' : '✗'} AppDynamics');

    buffer.writeln('Conversion Tracking:');
    buffer.writeln('  ${hasMetaPixel ? '✓' : '✗'} Meta Pixel');
    buffer.writeln('  ${hasLinkedInTag ? '✓' : '✗'} LinkedIn Insight Tag');

    return buffer.toString();
  }

  List<String> getDetectedAnalyticsTools() {
    final tools = <String>[];
    if (hasGoogleAnalytics) tools.add('Google Analytics');
    if (hasMixpanel) tools.add('Mixpanel');
    if (hasSegment) tools.add('Segment');
    if (hasAmplitude) tools.add('Amplitude');
    if (hasPostHog) tools.add('PostHog');
    if (hasPlausible) tools.add('Plausible');
    return tools;
  }

  List<String> getDetectedErrorTrackingTools() {
    final tools = <String>[];
    if (hasSentry) tools.add('Sentry');
    if (hasBugsnag) tools.add('Bugsnag');
    if (hasRollbar) tools.add('Rollbar');
    if (hasLogRocket) tools.add('LogRocket');
    return tools;
  }

  List<String> getDetectedPerformanceTools() {
    final tools = <String>[];
    if (hasNewRelic) tools.add('New Relic');
    if (hasDatadog) tools.add('Datadog');
    if (hasAppDynamics) tools.add('AppDynamics');
    return tools;
  }
}

/// Performance metrics from the live app
class PerformanceMetrics {
  final int pageLoadTime;
  final int ttfb;
  final int? dnsLookupTime;
  final int? tcpConnectionTime;
  final int? sslHandshakeTime;

  const PerformanceMetrics({
    required this.pageLoadTime,
    required this.ttfb,
    this.dnsLookupTime,
    this.tcpConnectionTime,
    this.sslHandshakeTime,
  });

  String get performanceRating {
    if (pageLoadTime < 1000) return 'Excellent';
    if (pageLoadTime < 2000) return 'Good';
    if (pageLoadTime < 3000) return 'Fair';
    return 'Poor';
  }
}

/// Security configuration of the live app
class SecurityConfig {
  final bool hasHttps;
  final bool hasHSTS;
  final bool hasCSP;
  final bool hasXFrameOptions;
  final bool hasXContentTypeOptions;
  final bool hasReferrerPolicy;
  final bool hasPermissionsPolicy;
  final bool hasCORS;

  final Map<String, String> securityHeaders;
  final List<CookieInfo> cookies;

  const SecurityConfig({
    required this.hasHttps,
    this.hasHSTS = false,
    this.hasCSP = false,
    this.hasXFrameOptions = false,
    this.hasXContentTypeOptions = false,
    this.hasReferrerPolicy = false,
    this.hasPermissionsPolicy = false,
    this.hasCORS = false,
    this.securityHeaders = const {},
    this.cookies = const [],
  });

  String toPromptString() {
    final buffer = StringBuffer();

    buffer.writeln('Security Headers:');
    buffer.writeln('  ${hasHttps ? '✓' : '✗'} HTTPS');
    buffer.writeln('  ${hasHSTS ? '✓' : '✗'} Strict-Transport-Security (HSTS)');
    buffer.writeln('  ${hasCSP ? '✓' : '✗'} Content-Security-Policy (CSP)');
    buffer.writeln('  ${hasXFrameOptions ? '✓' : '✗'} X-Frame-Options');
    buffer.writeln('  ${hasXContentTypeOptions ? '✓' : '✗'} X-Content-Type-Options');
    buffer.writeln('  ${hasReferrerPolicy ? '✓' : '✗'} Referrer-Policy');
    buffer.writeln('  ${hasPermissionsPolicy ? '✓' : '✗'} Permissions-Policy');
    buffer.writeln('  ${hasCORS ? '✓' : '✗'} CORS Headers');

    if (securityHeaders.isNotEmpty) {
      buffer.writeln('\nPresent Security Headers:');
      securityHeaders.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    if (cookies.isNotEmpty) {
      buffer.writeln('\nCookies Configuration:');
      for (final cookie in cookies) {
        buffer.writeln('  Cookie: ${cookie.name}');
        buffer.writeln('    Secure: ${cookie.isSecure}');
        buffer.writeln('    HttpOnly: ${cookie.isHttpOnly}');
        buffer.writeln('    SameSite: ${cookie.sameSite ?? 'none'}');
      }
    }

    return buffer.toString();
  }

  int get securityScore {
    int score = 0;
    if (hasHttps) score += 2;
    if (hasHSTS) score += 2;
    if (hasCSP) score += 2;
    if (hasXFrameOptions) score += 1;
    if (hasXContentTypeOptions) score += 1;
    if (hasReferrerPolicy) score += 1;
    if (hasPermissionsPolicy) score += 1;

    // Check cookies
    for (final cookie in cookies) {
      if (cookie.isSecure && cookie.isHttpOnly) score += 1;
    }

    return score;
  }

  String get securityRating {
    final score = securityScore;
    if (score >= 9) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 3) return 'Fair';
    return 'Poor';
  }
}

/// Cookie information
class CookieInfo {
  final String name;
  final bool isSecure;
  final bool isHttpOnly;
  final String? sameSite;

  const CookieInfo({
    required this.name,
    required this.isSecure,
    required this.isHttpOnly,
    this.sameSite,
  });
}

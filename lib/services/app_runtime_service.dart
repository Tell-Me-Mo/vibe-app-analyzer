import 'package:dio/dio.dart';
import '../models/runtime_analysis_data.dart';

/// Service for analyzing live deployed applications
class AppRuntimeService {
  final Dio _dio;

  AppRuntimeService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 500,
        ));

  /// Fetches and analyzes a live application
  Future<RuntimeAnalysisData> analyzeApp(String url) async {
    try {
      final totalStopwatch = Stopwatch()..start();
      final ttfbStopwatch = Stopwatch()..start();

      // Fetch the application
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent':
                'VibeCheck/1.0 (Security & Monitoring Analysis Tool)',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
        onReceiveProgress: (received, total) {
          // Stop TTFB timer on first byte received
          if (received > 0 && ttfbStopwatch.isRunning) {
            ttfbStopwatch.stop();
          }
        },
      );

      totalStopwatch.stop();

      // If onReceiveProgress wasn't triggered, stop the TTFB timer now
      if (ttfbStopwatch.isRunning) {
        ttfbStopwatch.stop();
      }

      final pageLoadTime = totalStopwatch.elapsedMilliseconds;
      final ttfb = ttfbStopwatch.elapsedMilliseconds;

      // Parse HTML content
      final html = response.data is String
          ? response.data as String
          : response.data.toString();

      // Detect monitoring tools
      final detectedTools = _detectTools(html);

      // Analyze security configuration
      final securityConfig = _analyzeSecurityConfig(url, response);

      // Calculate performance metrics
      final performanceMetrics = PerformanceMetrics(
        pageLoadTime: pageLoadTime,
        ttfb: ttfb,
      );

      return RuntimeAnalysisData(
        url: url,
        html: html,
        headers: response.headers.map,
        statusCode: response.statusCode ?? 200,
        ttfb: ttfb,
        pageLoadTime: pageLoadTime,
        detectedTools: detectedTools,
        performanceMetrics: performanceMetrics,
        securityConfig: securityConfig,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout: Could not reach $url. Please check if the URL is correct and accessible.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Response timeout: $url took too long to respond. The application may be slow or unresponsive.',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception(
          'Access forbidden: $url is blocking automated requests. Please check the application\'s security settings.',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception(
          'Not found: $url does not exist or has been moved.',
        );
      } else if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 500) {
        throw Exception(
          'Server error: $url returned status ${e.response!.statusCode}. The application may be experiencing issues.',
        );
      } else {
        throw Exception(
          'Failed to analyze application: ${e.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Unexpected error analyzing application: $e');
    }
  }

  /// Detects monitoring and analytics tools in the HTML
  DetectedTools _detectTools(String html) {
    // Convert to lowercase for case-insensitive matching
    final content = html.toLowerCase();

    return DetectedTools(
      // Analytics
      hasGoogleAnalytics: _detectGoogleAnalytics(content),
      hasMixpanel: _detectMixpanel(content),
      hasSegment: _detectSegment(content),
      hasAmplitude: _detectAmplitude(content),
      hasPostHog: _detectPostHog(content),
      hasPlausible: _detectPlausible(content),

      // Error Tracking
      hasSentry: _detectSentry(content),
      hasBugsnag: _detectBugsnag(content),
      hasRollbar: _detectRollbar(content),
      hasLogRocket: _detectLogRocket(content),

      // Session Replay
      hasHotjar: _detectHotjar(content),
      hasFullStory: _detectFullStory(content),

      // APM
      hasNewRelic: _detectNewRelic(content),
      hasDatadog: _detectDatadog(content),
      hasAppDynamics: _detectAppDynamics(content),

      // Conversion
      hasMetaPixel: _detectMetaPixel(content),
      hasLinkedInTag: _detectLinkedInTag(content),
    );
  }

  // Analytics detection methods
  bool _detectGoogleAnalytics(String html) {
    return html.contains('google-analytics.com/analytics.js') ||
        html.contains('googletagmanager.com/gtag/js') ||
        html.contains('ga_measurement_id') ||
        html.contains('gtag(') ||
        html.contains('ga(\'create') ||
        html.contains('google-analytics.com/ga.js');
  }

  bool _detectMixpanel(String html) {
    return html.contains('cdn.mxpnl.com') ||
        html.contains('mixpanel.init(') ||
        html.contains('mixpanel.track(');
  }

  bool _detectSegment(String html) {
    return html.contains('cdn.segment.com') ||
        html.contains('analytics.load(') ||
        html.contains('analytics.identify(');
  }

  bool _detectAmplitude(String html) {
    return html.contains('cdn.amplitude.com') ||
        html.contains('amplitude.getinstance(') ||
        html.contains('amplitude.init(');
  }

  bool _detectPostHog(String html) {
    return html.contains('posthog.') ||
        html.contains('app.posthog.com') ||
        html.contains('posthog-js');
  }

  bool _detectPlausible(String html) {
    return html.contains('plausible.io/js/') ||
        html.contains('plausible.io/api/');
  }

  // Error tracking detection methods
  bool _detectSentry(String html) {
    return html.contains('sentry.io') ||
        html.contains('sentry.init(') ||
        html.contains('browser.sentry-cdn.com') ||
        html.contains('@sentry/');
  }

  bool _detectBugsnag(String html) {
    return html.contains('bugsnag.com') ||
        html.contains('bugsnag.start(') ||
        html.contains('d2wy8f7a9ursnm.cloudfront.net');
  }

  bool _detectRollbar(String html) {
    return html.contains('rollbar.com') ||
        html.contains('rollbar.init(') ||
        html.contains('cdnjs.cloudflare.com/ajax/libs/rollbar.js');
  }

  bool _detectLogRocket(String html) {
    return html.contains('logrocket.com') ||
        html.contains('logrocket.init(') ||
        html.contains('cdn.logrocket.io');
  }

  // Session replay detection methods
  bool _detectHotjar(String html) {
    return html.contains('hotjar.com') ||
        html.contains('static.hotjar.com') ||
        html.contains('_hjsettings');
  }

  bool _detectFullStory(String html) {
    return html.contains('fullstory.com') ||
        html.contains('fs.identify(') ||
        html.contains('fullstory.init(');
  }

  // APM detection methods
  bool _detectNewRelic(String html) {
    return html.contains('newrelic.com') ||
        html.contains('nr-data.net') ||
        html.contains('nreum');
  }

  bool _detectDatadog(String html) {
    return html.contains('datadoghq.com') ||
        html.contains('dd.init(') ||
        html.contains('datadog-rum');
  }

  bool _detectAppDynamics(String html) {
    return html.contains('appdynamics.com') ||
        html.contains('adrum.js') ||
        html.contains('appdynamics');
  }

  // Conversion tracking detection methods
  bool _detectMetaPixel(String html) {
    return html.contains('facebook.com/tr') ||
        html.contains('connect.facebook.net') ||
        html.contains('fbq(') ||
        html.contains('facebook pixel');
  }

  bool _detectLinkedInTag(String html) {
    return html.contains('linkedin.com/px/') ||
        html.contains('snap.licdn.com') ||
        html.contains('_linkedin_partner_id');
  }

  /// Analyzes security configuration from response
  SecurityConfig _analyzeSecurityConfig(String url, Response response) {
    final headers = response.headers.map;
    final uri = Uri.parse(url);

    // Check for HTTPS
    final hasHttps = uri.scheme == 'https';

    // Extract security headers
    final securityHeaders = <String, String>{};
    final headerChecks = {
      'strict-transport-security': false,
      'content-security-policy': false,
      'x-frame-options': false,
      'x-content-type-options': false,
      'referrer-policy': false,
      'permissions-policy': false,
      'access-control-allow-origin': false,
    };

    headers.forEach((key, values) {
      final lowerKey = key.toLowerCase();
      if (headerChecks.containsKey(lowerKey)) {
        headerChecks[lowerKey] = true;
        securityHeaders[key] = values.join(', ');
      }
    });

    // Parse cookies
    final cookies = _parseCookies(headers);

    return SecurityConfig(
      hasHttps: hasHttps,
      hasHSTS: headerChecks['strict-transport-security']!,
      hasCSP: headerChecks['content-security-policy']!,
      hasXFrameOptions: headerChecks['x-frame-options']!,
      hasXContentTypeOptions: headerChecks['x-content-type-options']!,
      hasReferrerPolicy: headerChecks['referrer-policy']!,
      hasPermissionsPolicy: headerChecks['permissions-policy']!,
      hasCORS: headerChecks['access-control-allow-origin']!,
      securityHeaders: securityHeaders,
      cookies: cookies,
    );
  }

  /// Parses cookies from response headers
  List<CookieInfo> _parseCookies(Map<String, List<String>> headers) {
    final cookies = <CookieInfo>[];

    // Find set-cookie header (case-insensitive)
    List<String> setCookieHeaders = [];
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'set-cookie') {
        setCookieHeaders = entry.value;
        break;
      }
    }

    for (final cookieHeader in setCookieHeaders) {
      final parts = cookieHeader.split(';');
      if (parts.isEmpty) continue;

      final nameValue = parts[0].split('=');
      if (nameValue.isEmpty) continue;

      final name = nameValue[0].trim();
      final isSecure = cookieHeader.toLowerCase().contains('secure');
      final isHttpOnly = cookieHeader.toLowerCase().contains('httponly');

      String? sameSite;
      final sameSiteMatch = RegExp(r'samesite=(\w+)', caseSensitive: false)
          .firstMatch(cookieHeader);
      if (sameSiteMatch != null) {
        sameSite = sameSiteMatch.group(1);
      }

      cookies.add(CookieInfo(
        name: name,
        isSecure: isSecure,
        isHttpOnly: isHttpOnly,
        sameSite: sameSite,
      ));
    }

    return cookies;
  }
}

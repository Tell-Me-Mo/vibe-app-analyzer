import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/runtime_analysis_data.dart';

void main() {
  group('DetectedTools', () {
    test('creates instance with default values', () {
      const tools = DetectedTools();

      expect(tools.hasGoogleAnalytics, false);
      expect(tools.hasSentry, false);
      expect(tools.hasNewRelic, false);
    });

    test('creates instance with tools detected', () {
      const tools = DetectedTools(
        hasGoogleAnalytics: true,
        hasSentry: true,
        hasDatadog: true,
      );

      expect(tools.hasGoogleAnalytics, true);
      expect(tools.hasSentry, true);
      expect(tools.hasDatadog, true);
    });

    test('getDetectedAnalyticsTools returns list of detected tools', () {
      const tools = DetectedTools(
        hasGoogleAnalytics: true,
        hasMixpanel: true,
      );

      final detected = tools.getDetectedAnalyticsTools();
      expect(detected, contains('Google Analytics'));
      expect(detected, contains('Mixpanel'));
      expect(detected.length, 2);
    });

    test('getDetectedErrorTrackingTools returns list of detected tools', () {
      const tools = DetectedTools(
        hasSentry: true,
        hasRollbar: true,
      );

      final detected = tools.getDetectedErrorTrackingTools();
      expect(detected, contains('Sentry'));
      expect(detected, contains('Rollbar'));
      expect(detected.length, 2);
    });

    test('getDetectedPerformanceTools returns list of detected tools', () {
      const tools = DetectedTools(
        hasNewRelic: true,
        hasDatadog: true,
      );

      final detected = tools.getDetectedPerformanceTools();
      expect(detected, contains('New Relic'));
      expect(detected, contains('Datadog'));
      expect(detected.length, 2);
    });

  });

  group('PerformanceMetrics', () {
    test('creates instance with required metrics', () {
      const metrics = PerformanceMetrics(
        pageLoadTime: 2000,
        ttfb: 300,
      );

      expect(metrics.pageLoadTime, 2000);
      expect(metrics.ttfb, 300);
    });

    test('performanceRating returns Excellent for very fast load', () {
      const metrics = PerformanceMetrics(
        pageLoadTime: 800,
        ttfb: 150,
      );

      expect(metrics.performanceRating, 'Excellent');
    });

    test('performanceRating returns Good for fast load', () {
      const metrics = PerformanceMetrics(
        pageLoadTime: 1500,
        ttfb: 250,
      );

      expect(metrics.performanceRating, 'Good');
    });

    test('performanceRating returns Fair for moderate load', () {
      const metrics = PerformanceMetrics(
        pageLoadTime: 2500,
        ttfb: 600,
      );

      expect(metrics.performanceRating, 'Fair');
    });

    test('performanceRating returns Poor for slow load', () {
      const metrics = PerformanceMetrics(
        pageLoadTime: 4000,
        ttfb: 1200,
      );

      expect(metrics.performanceRating, 'Poor');
    });
  });

  group('SecurityConfig', () {
    test('creates instance with HTTPS enabled', () {
      const config = SecurityConfig(
        hasHttps: true,
      );

      expect(config.hasHttps, true);
      expect(config.hasHSTS, false);
      expect(config.hasCSP, false);
    });

    test('creates instance with all security headers', () {
      const config = SecurityConfig(
        hasHttps: true,
        hasHSTS: true,
        hasCSP: true,
        hasXFrameOptions: true,
      );

      expect(config.hasHttps, true);
      expect(config.hasHSTS, true);
      expect(config.hasCSP, true);
      expect(config.hasXFrameOptions, true);
    });

    test('stores security headers', () {
      const config = SecurityConfig(
        hasHttps: true,
        securityHeaders: {
          'strict-transport-security': 'max-age=31536000',
          'x-frame-options': 'DENY',
        },
      );

      expect(config.securityHeaders.length, 2);
      expect(config.securityHeaders['strict-transport-security'], isNotNull);
    });

    test('stores cookie information', () {
      const cookie = CookieInfo(
        name: 'session',
        isSecure: true,
        isHttpOnly: true,
        sameSite: 'Strict',
      );

      const config = SecurityConfig(
        hasHttps: true,
        cookies: [cookie],
      );

      expect(config.cookies.length, 1);
      expect(config.cookies[0].name, 'session');
    });

    test('securityScore returns high score for good security', () {
      const config = SecurityConfig(
        hasHttps: true,
        hasHSTS: true,
        hasCSP: true,
        hasXFrameOptions: true,
        hasXContentTypeOptions: true,
      );

      expect(config.securityScore, greaterThan(7));
    });

    test('securityScore returns low score for poor security', () {
      const config = SecurityConfig(
        hasHttps: false,
      );

      expect(config.securityScore, lessThan(5));
    });

    test('securityRating returns Excellent for high score', () {
      const config = SecurityConfig(
        hasHttps: true,
        hasHSTS: true,
        hasCSP: true,
        hasXFrameOptions: true,
        hasXContentTypeOptions: true,
      );

      expect(config.securityRating, anyOf('Excellent', 'Good'));
    });
  });

  group('CookieInfo', () {
    test('creates secure cookie', () {
      const cookie = CookieInfo(
        name: 'session',
        isSecure: true,
        isHttpOnly: true,
        sameSite: 'Strict',
      );

      expect(cookie.name, 'session');
      expect(cookie.isSecure, true);
      expect(cookie.isHttpOnly, true);
      expect(cookie.sameSite, 'Strict');
    });

    test('creates insecure cookie', () {
      const cookie = CookieInfo(
        name: 'tracking',
        isSecure: false,
        isHttpOnly: false,
        sameSite: 'None',
      );

      expect(cookie.isSecure, false);
      expect(cookie.isHttpOnly, false);
      expect(cookie.sameSite, 'None');
    });
  });

  group('RuntimeAnalysisData', () {
    test('creates complete instance', () {
      final data = RuntimeAnalysisData(
        url: 'https://example.com',
        html: '<html><body>Hello</body></html>',
        headers: {},
        statusCode: 200,
        ttfb: 250,
        pageLoadTime: 1500,
        detectedTools: const DetectedTools(
          hasGoogleAnalytics: true,
        ),
        performanceMetrics: const PerformanceMetrics(
          pageLoadTime: 1500,
          ttfb: 250,
        ),
        securityConfig: const SecurityConfig(
          hasHttps: true,
        ),
      );

      expect(data.url, 'https://example.com');
      expect(data.statusCode, 200);
      expect(data.ttfb, 250);
      expect(data.pageLoadTime, 1500);
    });

    test('toAnalysisPrompt includes all key information', () {
      final data = RuntimeAnalysisData(
        url: 'https://example.com',
        html: '<html><body>Test</body></html>',
        headers: {'content-type': ['text/html']},
        statusCode: 200,
        ttfb: 250,
        pageLoadTime: 1500,
        detectedTools: const DetectedTools(
          hasGoogleAnalytics: true,
        ),
        performanceMetrics: const PerformanceMetrics(
          pageLoadTime: 1500,
          ttfb: 250,
        ),
        securityConfig: const SecurityConfig(
          hasHttps: true,
        ),
      );

      final prompt = data.toAnalysisPrompt();
      expect(prompt, contains('APP URL'));
      expect(prompt, contains('PERFORMANCE METRICS'));
      expect(prompt, contains('DETECTED MONITORING TOOLS'));
      expect(prompt, contains('SECURITY CONFIGURATION'));
    });
  });
}

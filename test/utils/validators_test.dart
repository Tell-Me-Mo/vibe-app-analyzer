import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/analysis_mode.dart';
import 'package:vibecheck/utils/validators.dart';

void main() {
  group('URL Validators', () {
    group('isValidGitHubUrl', () {
      test('rejects invalid GitHub URLs', () {
        expect(Validators.isValidGitHubUrl('https://gitlab.com/user/repo'), false);
        expect(Validators.isValidGitHubUrl('https://github.com'), false);
        expect(Validators.isValidGitHubUrl('not-a-url'), false);
        expect(Validators.isValidGitHubUrl(''), false);
      });

      test('rejects malformed URLs', () {
        expect(Validators.isValidGitHubUrl('github.com/user/repo'), false);
        expect(Validators.isValidGitHubUrl('https://github.com/'), false);
        expect(Validators.isValidGitHubUrl('https://github.com/user'), false);
      });
    });

    group('isValidAppUrl', () {
      test('accepts valid app URLs', () {
        expect(Validators.isValidAppUrl('https://example.com'), true);
        expect(Validators.isValidAppUrl('https://app.example.com'), true);
        expect(Validators.isValidAppUrl('https://example.com/path'), true);
        expect(Validators.isValidAppUrl('http://localhost:3000'), true);
      });

      test('rejects GitHub URLs', () {
        expect(Validators.isValidAppUrl('https://github.com/user/repo'), false);
        expect(Validators.isValidAppUrl('https://www.github.com/user/repo'), false);
      });

      test('accepts GitHub Pages URLs', () {
        expect(Validators.isValidAppUrl('https://username.github.io'), true);
        expect(Validators.isValidAppUrl('https://username.github.io/project'), true);
      });

      test('rejects invalid URLs', () {
        expect(Validators.isValidAppUrl('not-a-url'), false);
        expect(Validators.isValidAppUrl(''), false);
        expect(Validators.isValidAppUrl('ftp://example.com'), false);
      });

      test('handles edge cases', () {
        expect(Validators.isValidAppUrl('https://'), false);
        expect(Validators.isValidAppUrl('http://'), false);
        expect(Validators.isValidAppUrl('  https://example.com  '), true);
      });
    });

    group('detectUrlType', () {
      test('detects app URLs as runtime', () {
        expect(
          Validators.detectUrlType('https://example.com'),
          AnalysisMode.runtime,
        );
        expect(
          Validators.detectUrlType('https://myapp.vercel.app'),
          AnalysisMode.runtime,
        );
        expect(
          Validators.detectUrlType('https://user.github.io'),
          AnalysisMode.runtime,
        );
      });

      test('returns null for invalid URLs', () {
        expect(Validators.detectUrlType('not-a-url'), null);
        expect(Validators.detectUrlType(''), null);
        expect(Validators.detectUrlType('ftp://example.com'), null);
      });

      test('handles whitespace for app URLs', () {
        expect(
          Validators.detectUrlType('  https://example.com  '),
          AnalysisMode.runtime,
        );
      });
    });
  });
}

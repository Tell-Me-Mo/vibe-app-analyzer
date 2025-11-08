import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/analysis_mode.dart';

void main() {
  group('AnalysisMode', () {
    group('displayName', () {
      test('returns correct display name for staticCode', () {
        expect(AnalysisMode.staticCode.displayName, 'Static Code');
      });

      test('returns correct display name for runtime', () {
        expect(AnalysisMode.runtime.displayName, 'Runtime');
      });
    });

    group('shortLabel', () {
      test('returns correct short label for staticCode', () {
        expect(AnalysisMode.staticCode.shortLabel, 'Code');
      });

      test('returns correct short label for runtime', () {
        expect(AnalysisMode.runtime.shortLabel, 'Live');
      });
    });

    group('icon', () {
      test('returns correct icon for staticCode', () {
        expect(AnalysisMode.staticCode.icon, '📝');
      });

      test('returns correct icon for runtime', () {
        expect(AnalysisMode.runtime.icon, '🚀');
      });
    });

    group('description', () {
      test('returns correct description for staticCode', () {
        expect(
          AnalysisMode.staticCode.description,
          'Analyzes source code from GitHub repository',
        );
      });

      test('returns correct description for runtime', () {
        expect(
          AnalysisMode.runtime.description,
          'Analyzes deployed live application',
        );
      });
    });

    group('JSON serialization', () {
      test('toJson returns name', () {
        expect(AnalysisMode.staticCode.toJson(), 'staticCode');
        expect(AnalysisMode.runtime.toJson(), 'runtime');
      });

      test('fromJson parses staticCode', () {
        expect(AnalysisMode.fromJson('staticCode'), AnalysisMode.staticCode);
      });

      test('fromJson parses runtime', () {
        expect(AnalysisMode.fromJson('runtime'), AnalysisMode.runtime);
      });

      test('fromJson defaults to staticCode for invalid input', () {
        expect(AnalysisMode.fromJson('invalid'), AnalysisMode.staticCode);
        expect(AnalysisMode.fromJson(''), AnalysisMode.staticCode);
      });
    });

    group('enum values', () {
      test('has exactly 2 values', () {
        expect(AnalysisMode.values.length, 2);
      });

      test('contains staticCode and runtime', () {
        expect(AnalysisMode.values, contains(AnalysisMode.staticCode));
        expect(AnalysisMode.values, contains(AnalysisMode.runtime));
      });
    });
  });
}

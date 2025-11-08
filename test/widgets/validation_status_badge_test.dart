import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/validation_status.dart';
import 'package:vibecheck/widgets/common/validation_status_badge.dart';

void main() {
  group('ValidationStatusBadge', () {
    testWidgets('renders with passed status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.passed),
          ),
        ),
      );

      expect(find.text('✅'), findsOneWidget);
      expect(find.text('Fix Validated'), findsOneWidget);
    });

    testWidgets('renders with failed status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.failed),
          ),
        ),
      );

      expect(find.text('❌'), findsOneWidget);
      expect(find.text('Fix Failed'), findsOneWidget);
    });

    testWidgets('renders with validating status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.validating),
          ),
        ),
      );

      expect(find.text('🔄'), findsOneWidget);
      expect(find.text('Validating...'), findsOneWidget);
    });

    testWidgets('renders with error status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.error),
          ),
        ),
      );

      expect(find.text('⚠️'), findsOneWidget);
      expect(find.text('Validation Error'), findsOneWidget);
    });

    testWidgets('renders with notStarted status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.notStarted),
          ),
        ),
      );

      expect(find.text('⚪'), findsOneWidget);
      expect(find.text('Not Validated'), findsOneWidget);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationStatusBadge(status: ValidationStatus.passed),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull);
    });
  });
}

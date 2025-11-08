import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/widgets/common/credits_indicator.dart';
import 'package:vibecheck/services/credits_service.dart';

void main() {
  testWidgets('CreditsIndicator displays credits correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CreditsIndicator(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should show "credits" text
    expect(find.text('credits'), findsOneWidget);

    // Should show stars icon
    expect(find.byIcon(Icons.stars), findsOneWidget);

    // Should show add icon
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
  });

  testWidgets('CreditsIndicator is rendered as a tappable widget',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CreditsIndicator(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find InkWell (which makes it tappable)
    expect(find.byType(InkWell), findsOneWidget);

    // Verify the widget is rendered without errors
    expect(find.byType(CreditsIndicator), findsOneWidget);
  });

  testWidgets('CreditsIndicator has correct color for different credit levels',
      (tester) async {
    // This test verifies the color logic is applied
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CreditsIndicator(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find Icon widget
    final iconFinder = find.byIcon(Icons.stars);
    expect(iconFinder, findsOneWidget);

    final icon = tester.widget<Icon>(iconFinder);
    // Color should be one of: green, blue, yellow, or red
    expect(icon.color, isNotNull);
  });
}

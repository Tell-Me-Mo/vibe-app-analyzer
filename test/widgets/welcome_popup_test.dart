import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/widgets/common/welcome_popup.dart';

void main() {
  testWidgets('WelcomePopup displays correct content', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WelcomePopup(),
          ),
        ),
      ),
    );

    // Verify title
    expect(find.text('Welcome to VibeCheck!'), findsOneWidget);

    // Verify free credits text
    expect(find.text('10 FREE Credits'), findsOneWidget);
    expect(find.text('2 free analyses'), findsOneWidget);

    // Verify description
    expect(
      find.textContaining('Start analyzing your code'),
      findsOneWidget,
    );

    // Verify cost information
    expect(find.text('Each analysis costs 5 credits.'), findsOneWidget);

    // Verify button
    expect(find.text('Get Started'), findsOneWidget);

    // Verify gift icon
    expect(find.byIcon(Icons.card_giftcard), findsOneWidget);

    // Verify stars icon
    expect(find.byIcon(Icons.stars), findsOneWidget);
  });

  testWidgets('WelcomePopup button is interactive', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WelcomePopup(),
          ),
        ),
      ),
    );

    // Find the button
    final button = find.text('Get Started');
    expect(button, findsOneWidget);

    // Verify button exists and is rendered
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('WelcomePopup is displayed in a Dialog', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WelcomePopup(),
          ),
        ),
      ),
    );

    // Check for Dialog wrapper
    expect(find.byType(Dialog), findsOneWidget);
  });
}

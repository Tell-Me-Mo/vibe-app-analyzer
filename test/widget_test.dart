import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        child: App(),
      ),
    );

    // Pump and settle to let async operations complete
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('VibeCheck'), findsOneWidget);
  });
}

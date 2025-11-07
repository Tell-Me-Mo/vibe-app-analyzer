import 'package:flutter_test/flutter_test.dart';
import 'package:app_analyzer/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppAnalyzerApp());

    // Verify that the app title is present
    expect(find.text('App Analyzer'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:taekwondo_app/main.dart'; // Import the main app file

void main() {
  testWidgets('App loads and displays home screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const StruerTKDApp());

    // Verify that the home screen is displayed.
    expect(find.text('Struer TKD Club'), findsOneWidget);
  });
}
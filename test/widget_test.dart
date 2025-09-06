import 'package:flutter_test/flutter_test.dart';

import 'package:celestia/main.dart';

void main() {
  testWidgets('App loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CelestiaApp());

    // Pump a few frames to allow initial animations to start
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Discover the weather'), findsOneWidget);
  });
}

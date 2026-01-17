// Basic Flutter widget test for Team Management App
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:team_management_app_dev/main.dart';

void main() {
  // smoke test ensures app builds without error
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // builds app widget tree and renders first frame
    await tester.pumpWidget(const MyApp());

    // checks counter starts at zero
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // simulates user tapping increment button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // verifies counter increased to one
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

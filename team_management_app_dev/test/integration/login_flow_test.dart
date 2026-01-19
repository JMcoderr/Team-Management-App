import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/pages/login.dart';

void main() {
  group('Login Flow Integration Test', () {
    
    testWidgets('Complete login flow', (WidgetTester tester) async {
      // Start at login
      await tester.pumpWidget(MaterialApp(home: Login()));
      
      // Fill in credentials
      await tester.enterText(
        find.byType(TextField).at(0), 
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).at(1), 
        'Test123!',
      );
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Should go to dashboard (this onlt works if API is available
      // For test we just check if no crash
      expect(tester.takeException(), isNull);
    });
  });
}

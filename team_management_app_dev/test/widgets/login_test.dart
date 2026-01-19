import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/pages/login.dart';

void main() {
  group('Login Page Tests', () {
    
    // Test if login page loads
    testWidgets('Login page should render', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        MaterialApp(home: Login()),
      );
      
      // Check if email field exists
      expect(find.byType(TextField), findsWidgets);
      
      // Check if login button exists
      expect(find.text('Login'), findsOneWidget);
    });
    
    // Test if you can enter text
    testWidgets('Should accept email input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Login()));
      
      // Find first textfield (email)
      final emailField = find.byType(TextField).first;
      
      // Type email
      await tester.enterText(emailField, 'test@test.nl');
      
      // Check if its in there
      expect(find.text('test@test.nl'), findsOneWidget);
    });
  });
}

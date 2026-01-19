import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_management_app_dev/pages/dashboard_page.dart';

void main() {
  group('Dashboard Tests', () {
    
    // Test if dashboard loads
    testWidgets('Dashboard should show title', (WidgetTester tester) async {
      // Build dashboard with provider
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: DashboardPage()),
        ),
      );
      
      // Wait until everything is loaded
      await tester.pump();
      
      // Check if Dashboard title exists
      expect(find.text('Dashboard'), findsOneWidget);
    });
    
    // Test if stats cards are there
    testWidgets('Should show stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: DashboardPage()),
        ),
      );
      
      await tester.pump();
      
      // Check if Quick Stats is there
      expect(find.text('Quick Stats'), findsOneWidget);
      
      // Check if card titles are there
      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    });
  });
}

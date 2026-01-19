import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_management_app_dev/pages/schedule_page.dart';

void main() {
  group('Schedule Page Tests', () {
    
    // Test if schedule loads
    testWidgets('Schedule page renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: SchedulePage()),
        ),
      );
      
      // Check if title exists
      expect(find.text('Schedule'), findsOneWidget);
      
      // Check if week navigation exists
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
    
    // Test if you can change week
    testWidgets('Can navigate to next week', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: SchedulePage()),
        ),
      );
      
      await tester.pump();
      
      // Click on next week button
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      
      // Page should update (no error)
      expect(tester.takeException(), isNull);
    });
    
    // Test if days are shown
    testWidgets('Shows all weekdays', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: SchedulePage()),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check if day names are there
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
    });
  });
}

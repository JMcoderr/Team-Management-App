import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/widgets/stats_card.dart';

void main() {
  group('StatsCard Tests', () {
    
    // Test if card renders with data
    testWidgets('StatsCard shows correct data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Teams',
              value: '5',
              icon: Icons.group,
            ),
          ),
        ),
      );
      
      // Check if title exists
      expect(find.text('Teams'), findsOneWidget);
      
      // Check if value exists
      expect(find.text('5'), findsOneWidget);
      
      // Check if icon exists
      expect(find.byIcon(Icons.group), findsOneWidget);
    });
    
    // Test if card is a Card widget
    testWidgets('StatsCard is a Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Test',
              value: '10',
              icon: Icons.event,
            ),
          ),
        ),
      );
      
      // Check if its a Card
      expect(find.byType(Card), findsOneWidget);
    });
  });
}

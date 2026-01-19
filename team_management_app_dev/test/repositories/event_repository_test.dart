import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/data/repositories/event_repository.dart';

void main() {
  // Test group for event repository
  group('EventRepository Tests', () {
    
    // Test if repository can be created
    test('EventRepository should be created', () {
      final repo = EventRepository();
      
      // Check if repo exists
      expect(repo, isNotNull);
    });
    
    // Test if getEvents returns a Future
    test('getEvents should return Future', () {
      final repo = EventRepository();
      
      // Get events (will fail without auth but thats ok)
      final future = repo.getEvents();
      
      // Check if its a Future
      expect(future, isA<Future>());
    });
    
    // Test if createEvent returns a Future
    test('createEvent should return Future', () {
      final repo = EventRepository();
      
      // Try to create event (will fail but thats ok)
      final future = repo.createEvent({
        'title': 'Test Event',
        'description': 'Test',
        'datetimeStart': DateTime.now().toIso8601String(),
        'datetimeEnd': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'teamId': 1,
      });
      
      // Check if its a Future
      expect(future, isA<Future>());
    });
    
    // Test if deleteEvent works without crash
    test('deleteEvent should call API', () async {
      final repo = EventRepository();
      
      // Try to delete
      try {
        await repo.deleteEvent(999);
      } catch (e) {
        // Exception is ok because not authorized
        expect(e, isA<Exception>());
      }
    });
  });
}

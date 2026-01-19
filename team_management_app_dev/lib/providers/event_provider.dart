import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';

// Simple local storage for locations (API doesn't support it)
final Map<int, String> eventLocations = {};

// Provides EventRepository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// Gets all events
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  final events = await repository.getEvents();

  // Apply saved locations to events
  for (var event in events) {
    if (eventLocations.containsKey(event.id)) {
      event.location = eventLocations[event.id]!;
    }
  }

  return events;
});

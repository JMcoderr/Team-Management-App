import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';
import '../data/services/api_service.dart';

// Provider for API service (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider for event repository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EventRepository(apiService);
});

// Provider for all events
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

// Provider for upcoming events only
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents();
});

// Provider for past events only
final pastEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getPastEvents();
});

// State provider for search query
final searchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

// State provider for selected filter tab
final selectedFilterProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

// Provider for filtered events (combines search + filter)
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedFilter = ref.watch(selectedFilterProvider);

  return eventsAsync.when(
    data: (events) {
      // Apply filter (All/Upcoming/Past)
      var filtered = events;
      if (selectedFilter == 1) {
        filtered = events.where((e) => e.type == 'upcoming').toList();
      } else if (selectedFilter == 2) {
        filtered = evebased on selected tab
      var filtered = events;
      if (selectedFilter == 1) {
        filtered = events.where((e) => e.type == 'upcoming').toList();
      } else if (selectedFilter == 2) {
        filtered = events.where((e) => e.type == 'past').toList();
      }

      // Apply search if there's at.location.toLowerCase().contains(query);
        }).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

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
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

// State provider for selected filter tab
final selectedFilterProvider = NotifierProvider<SelectedFilterNotifier, int>(() {
  return SelectedFilterNotifier();
});

class SelectedFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void update(int index) => state = index;
}

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
        filtered = events.where((e) => e.type == 'past').toList();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered.where((event) {
          return event.title.toLowerCase().contains(query) ||
                 event.location.toLowerCase().contains(query);
        }).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

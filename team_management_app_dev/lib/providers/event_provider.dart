import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';
import '../data/services/api_service.dart';

// provides ApiService instance for HTTP requests
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// provides EventRepository with API service dependency
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EventRepository(apiService);
});

// fetches all events from repository
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

// fetches only upcoming events 
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents();
});

// fetches only past events 
final pastEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getPastEvents();
});

// manages search query string state
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

// notifier holds current search text
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

// tracks selected filter tab 
final selectedFilterProvider = NotifierProvider<SelectedFilterNotifier, int>(
  () {
    return SelectedFilterNotifier();
  },
);

// notifier holds active filter tab index
class SelectedFilterNotifier extends Notifier<int> {
  @override
  int build() => 1; 
  void update(int index) => state = index;
}

// combines events with search and filter settings
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedFilter = ref.watch(selectedFilterProvider);

  return eventsAsync.when(
    data: (events) {
      // applies tab filter first
      var filtered = events;
      if (selectedFilter == 1) {
        filtered = events.where((e) => e.type == 'upcoming').toList();
      } else if (selectedFilter == 2) {
        filtered = events.where((e) => e.type == 'past').toList();
      }

      // applies search filter to title and location
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered.where((event) {
          return event.title.toLowerCase().contains(query) ||
              event.location.toLowerCase().contains(query);
        }).toList();
      }

      // sorts events to show upcoming first, then past
      filtered.sort((a, b) {
        // determines event timing based on type
        bool aIsFuture = a.type == 'upcoming';
        bool bIsFuture = b.type == 'upcoming';

        // prioritizes upcoming over past events
        if (aIsFuture && !bIsFuture) return -1;
        if (!aIsFuture && bIsFuture) return 1;

        // sorts within each category by date and time
        if (aIsFuture) {
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) return dateComparison; 

          // same date: sorts by time (earliest first)
          return a.time.compareTo(b.time);
        } else {
          // compares dates for past events
          int dateComparison = b.date.compareTo(a.date);
          if (dateComparison != 0)
            return dateComparison;

          return b.time.compareTo(a.time);
        }
      });

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

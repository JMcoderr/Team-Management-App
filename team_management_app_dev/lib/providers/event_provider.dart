import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';
import '../data/services/api_service.dart';

// api service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// event repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EventRepository(apiService);
});

// all events provider
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

// upcoming events provider
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents();
});

// past events provider
final pastEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getPastEvents();
});

// search query provider
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

// filter tab provider
final selectedFilterProvider = NotifierProvider<SelectedFilterNotifier, int>(() {
  return SelectedFilterNotifier();
});

class SelectedFilterNotifier extends Notifier<int> {
  @override
  int build() => 1;  // Default to upcoming (1 instead of 0)
  
  void update(int index) => state = index;
}

// filtered events provider
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

      // sort events by date and time - future events first (blue), then past events (grey)
      filtered.sort((a, b) {
        // check if event is in future or past
        bool aIsFuture = a.type == 'upcoming';
        bool bIsFuture = b.type == 'upcoming';
        
        // if one is future and other is past, future comes first
        if (aIsFuture && !bIsFuture) return -1;
        if (!aIsFuture && bIsFuture) return 1;
        
        // if both same type, sort by date (newest first for future, oldest first for past)
        if (aIsFuture) {
          // Compare dates first
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) return dateComparison; // upcoming events: soonest first
          
          // If same date, sort by time (earliest first)
          return a.time.compareTo(b.time);
        } else {
          // Compare dates first
          int dateComparison = b.date.compareTo(a.date);
          if (dateComparison != 0) return dateComparison; // past events: most recent first
          
          // If same date, sort by time (latest first for past events)
          return b.time.compareTo(a.time);
        }
      });

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

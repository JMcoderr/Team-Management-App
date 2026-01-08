import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';
import '../data/services/api_service.dart';

// ==================== PROVIDERS ====================
// Providers = Notes on the bulletin board that everyone can read

/// API Service Provider - The waiter (singleton = one waiter for whole app)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Event Repository Provider - The librarian (singleton)
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EventRepository(apiService);
});

/// Events List Provider - The current list of events on the bulletin board
/// 
/// This is like a live-updating board:
/// - When events change, everyone watching sees the update
/// - AsyncValue = can be loading, error, or success
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

/// Upcoming Events Provider - Filtered list (only future events)
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents();
});

/// Past Events Provider - Filtered list (only old events)
final pastEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getPastEvents();
});

/// Search Query Provider - What the user is searching for (can change)
final searchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

/// Selected Filter Provider - Which tab is selected (0=All, 1=Upcoming, 2=Past)
final selectedFilterProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

/// Filtered Events Provider - Events that match search + filter
/// 
/// This automatically updates when:
/// - Search query changes
/// - Selected filter changes
/// - Events list changes
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

      // Apply search query
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

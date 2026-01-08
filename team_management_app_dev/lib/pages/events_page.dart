import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/event_provider.dart';

// Events page - shows list of all events with filters
class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                // Update search query in provider
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // FILTER TABS (All, Upcoming, Past)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Upcoming', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Past', 2),
              ],
            ),
          ),

          // EVENT LIST
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open add event form
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Event - Coming Soon!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Helper: Build a filter chip (All/Upcoming/Past button)
  Wi Helper to build filter chips
    final selectedFilter = ref.watch(selectedFilterProvider);
    final bool isSelected = selectedFilter == index;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // UPDATE the bulletin board
        ref.pdate selected filterder.notifier).state = index;
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  // Build the event list from API
  Widget _buildEventList() {
    // Watch the filtered events provider
    final filteredEventsAsync = ref.watch(filteredEventsProvider);

    // Handle loading, error, and success states
    return filteredEventsAsync.when(
      // Loading state
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading events from API...'),
          ],
        ),
      ),

      // STATE 2: Error (show error message)
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         Error state
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Retry: Refresh the provider
                ref.refresh(eventsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: con by refreshingTry Again'),
            ),
          ],
        ),
      ),

      // STATE 3: Success (show the events!)
      data: (events) {
        // If no events match, show empty state
        if (events.isEmpty) {
          uccess state - show events
      data: (events) {
        // Show empty state if no events matchent.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.watch(searchQueryProvider).isNotEmpty
                      ? 'Try a different search'
                      : 'Check back later!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Show list of events from API
        return RefreshIndicator(
          // Pull-to-refresh: Swipe down to reload from API
          onRefresh: () async {
            ref.refrewith pull-to-refresh
        return RefreshIndicator(
          // Swipe down to refresh
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                title: event.title,
                date: '${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}/${event.date.year}',
                time: event.time,
                location: event.location,
                icon: _getIconForType(event.iconType),
                iconColor: event.type == 'upcoming' ? Colors.blue : Colors.grey,
              );
            },
          ),
        );
      },
    );
  }

  // Helper to get icon based on event type
  IconData _getIconForType(String iconType) {
    switch (iconType) {
      case 'training':
        return Icons.fitness_center;
      case 'meeting':
        return Icons.meeting_room;
      case 'match':
        return Icons.sports_soccer;
      default:
        return Icons.event_note;
    }
  }
}

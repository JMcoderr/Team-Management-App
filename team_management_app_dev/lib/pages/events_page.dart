import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/event_provider.dart';

// showing all events with filter options
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
          // searchbar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
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

          // filter buttons
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

          // list of events
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: add event form
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

  // creating filter buttons
  Widget _buildFilterChip(String label, int index) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final bool isSelected = selectedFilter == index;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // change selected filter
        ref.read(selectedFilterProvider.notifier).update(index);
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

  // showing events in a list
  Widget _buildEventList() {
    final eventsData = ref.watch(filteredEventsProvider);

    return eventsData.when(
      // when loading
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading events...'),
          ],
        ),
      ),

      // if error happens
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
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
                // try again
                ref.invalidate(eventsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),

      // Success state 
      data: (events) {
        // Show empty state if no events match
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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

        // showing events
        return RefreshIndicator(
          onRefresh: () async {
            // refresh when pulled down
            ref.invalidate(eventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
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

  // getting icon for event type
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

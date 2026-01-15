import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/stats_card.dart';
import '../providers/event_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // getting the events from provider
    final eventsAsync = ref.watch(eventsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (allEvents) {
          // calculating stats
          final totalEvents = allEvents.length;
          
          // events this week
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          final thisWeekEvents = allEvents.where((event) {
            return event.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   event.date.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).length;

          return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // greeting text
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here\'s your team overview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // stats
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // grid with stats cards
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // teams stat (still hardcoded - waiting for teams feature)
                StatsCard(
                  title: 'Teams',
                  value: '5',
                  icon: Icons.group,
                ),
                // events stat - now real!
                StatsCard(
                  title: 'Events',
                  value: '$totalEvents',
                  icon: Icons.calendar_today,
                ),
                // this week stat - now real!
                StatsCard(
                  title: 'This Week',
                  value: '$thisWeekEvents',
                  icon: Icons.event_note,
                ),
                // members stat (still hardcoded - waiting for teams feature)
                StatsCard(
                  title: 'Members',
                  value: '24',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Upcoming events section
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // showing real upcoming events now!
            ...upcomingEvents.when(
              loading: () => [const CircularProgressIndicator()],
              error: (err, stack) => [Text('Error loading events: $err')],
              data: (events) {
                // take only first 3 upcoming events
                final displayEvents = events.take(3).toList();
                
                if (displayEvents.isEmpty) {
                  return [
                    const Text(
                      'No upcoming events yet. Create one in the Organise page!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ];
                }
                
                // build event items for each event
                return displayEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEventItem(
                      title: event.title,
                      date: DateFormat('dd/MM/yyyy').format(event.date),
                      location: event.location,
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  // building event item
  Widget _buildEventItem({
    required String title,
    required String date,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

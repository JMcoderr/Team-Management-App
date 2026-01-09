import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/event_provider.dart';

// showing YOUR schedule (events from teams you're in)
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  String? selectedTeam; // which team is selected in dropdown (null = all teams)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // filter by team dropdown
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedTeam,
                isExpanded: true,
                hint: const Text('All teams'),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down),
                items: [
                  // all teams option
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(Icons.group, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('All teams'),
                      ],
                    ),
                  ),
                  // TODO: jay will add actual teams later
                  const DropdownMenuItem<String>(
                    value: 'Dragons FC',
                    child: Row(
                      children: [
                        Icon(Icons.sports_soccer, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Dragons FC'),
                      ],
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Code Warriors',
                    child: Row(
                      children: [
                        Icon(Icons.sports_soccer, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Code Warriors'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTeam = value;
                  });
                },
              ),
            ),
          ),

          // event list for your teams
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  // showing YOUR events (from teams you're in)
  Widget _buildEventList() {
    // get all events first
    final eventsData = ref.watch(eventsProvider);

    return eventsData.when(
      // when loading
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your schedule...'),
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
              'Something went wrong...',
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

      // when we got the data
      data: (events) {
        // filter events by selected team if any
        final filteredEvents = selectedTeam == null
            ? events // show all events
            : events.where((event) {
                // TODO: when jay adds team data to events, filter properly
                // for now just showing all events
                return true;
              }).toList();

        // if no events
        if (filteredEvents.isEmpty) {
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
                  selectedTeam == null
                      ? 'No events scheduled yet'
                      : 'No events for this team',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // showing events in a list
        return RefreshIndicator(
          onRefresh: () async {
            // refresh when pulled down
            ref.invalidate(eventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredEvents.length,
            itemBuilder: (context, i) {
              final event = filteredEvents[i];
              
              // picking icon based on type
              IconData icon;
              if (event.iconType == 'match') {
                icon = Icons.sports_soccer;
              } else if (event.iconType == 'training') {
                icon = Icons.fitness_center;
              } else if (event.iconType == 'meeting') {
                icon = Icons.people;
              } else {
                icon = Icons.event;
              }
              
              return EventCard(
                title: event.title,
                date: '${event.date.day}/${event.date.month}/${event.date.year}',
                location: event.location,
                time: event.time,
                icon: icon,
                iconColor: Colors.blue, // all blue icons
              );
            },
          ),
        );
      },
    );
  }
}

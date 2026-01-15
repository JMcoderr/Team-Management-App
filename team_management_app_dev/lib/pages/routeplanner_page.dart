import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// planning routes to event locations
class RouteplannerPage extends ConsumerStatefulWidget {
  const RouteplannerPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RouteplannerPage> createState() => _RouteplannerPageState();
}

class _RouteplannerPageState extends ConsumerState<RouteplannerPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planner'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // event locations list
          Expanded(
            child: upcomingEvents.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (events) {
                // filtering by search
                final filteredEvents = events.where((event) {
                  return event.title.toLowerCase().contains(searchQuery) ||
                      event.location.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty 
                              ? 'No upcoming events to plan routes for!'
                              : 'No events found matching "$searchQuery"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return _buildLocationCard(event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // building card for each event location
  Widget _buildLocationCard(event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // event title
            Row(
              children: [
                // icon based on event type
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    event.iconType == 'match' 
                        ? Icons.sports_soccer 
                        : event.iconType == 'training'
                            ? Icons.fitness_center
                            : Icons.event,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(event.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // location info
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.red[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.blue[400]),
                const SizedBox(width: 8),
                Text(
                  event.time,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // buttons for navigation
            Row(
              children: [
                // google maps button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(event.location),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // directions button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openDirections(event.location),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // opening google maps for location
  Future<void> _openGoogleMaps(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // opening directions to location
  Future<void> _openDirections(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    // this opens google maps with directions from current location
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedLocation');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open directions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

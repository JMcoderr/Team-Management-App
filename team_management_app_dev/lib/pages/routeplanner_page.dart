import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Route planner page - shows upcoming events with Google Maps links
class RouteplannerPage extends ConsumerWidget {
  const RouteplannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get events from provider
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planner'),
        backgroundColor: Colors.blue,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (events) {
          // Filter to only upcoming events
          final upcomingEvents = events
              .where((e) => e.type == 'upcoming')
              .toList();

          if (upcomingEvents.isEmpty) {
            return const Center(child: Text('No upcoming events'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.location}\n${event.date.day}/${event.date.month}/${event.date.year} at ${event.time}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.directions),
                    color: Colors.blue,
                    onPressed: () async {
                      // Build Google Maps URL with location
                      final query = Uri.encodeComponent(event.location);
                      final url =
                          'https://www.google.com/maps/search/?api=1&query=$query';

                      // Try to open in browser

                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open maps'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

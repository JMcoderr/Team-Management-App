import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';
import '../utils/date_formatter.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
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
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: 3,
                itemBuilder: (context, index) => const CardSkeleton(),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: AppColors.error),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Error loading events',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        err.toString(),
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (events) {
                // Only show events with both Google Maps links
                final eventsWithLinks = events.where((event) {
                  return event.googleMapsLink != null && 
                         event.googleMapsLink!.isNotEmpty &&
                         event.directionsLink != null && 
                         event.directionsLink!.isNotEmpty;
                }).toList();
                
                // filtering by search
                final filteredEvents = eventsWithLinks.where((event) {
                  return event.title.toLowerCase().contains(searchQuery) ||
                      event.location.toLowerCase().contains(searchQuery);
                }).toList();
                
                // Sort by date and time (earliest first)
                filteredEvents.sort((a, b) {
                  int dateComparison = a.date.compareTo(b.date);
                  if (dateComparison != 0) return dateComparison;
                  return a.time.compareTo(b.time);
                });

                if (filteredEvents.isEmpty) {
                  return EmptyState(
                    icon: Icons.map_outlined,
                    title: searchQuery.isEmpty ? 'No upcoming events' : 'No events found',
                    message: searchQuery.isEmpty
                        ? 'Create upcoming events to plan routes to their locations.'
                        : 'No events found matching "$searchQuery".',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(upcomingEventsProvider);
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildLocationCard(event);
                    },
                  ),
                );
              },
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  // building card for each event location
  Widget _buildLocationCard(event) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                  color: EventTypeHelper.getColor(event.iconType),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  EventTypeHelper.getIcon(event.iconType),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      DateFormatter.formatRelativeDate(event.date),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // location info
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColors.error),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  event.location,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                event.time,
                style: AppTextStyles.body,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // buttons for navigation
          Row(
            children: [
              // google maps button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(event),
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // directions button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(event),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // opening google maps for location
  Future<void> _openGoogleMaps(event) async {
    String urlString;
    
    // Use stored Google Maps link if available
    if (event.googleMapsLink != null && event.googleMapsLink!.isNotEmpty) {
      urlString = event.googleMapsLink!;
    }
    // Otherwise use coordinates if available for more accurate location
    else if (event.latitude != null && event.longitude != null) {
      urlString = 'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}';
    } else {
      final encodedLocation = Uri.encodeComponent(event.location);
      urlString = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
    }
    
    final url = Uri.parse(urlString);
    
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
  Future<void> _openDirections(event) async {
    String urlString;
    
    // Use stored directions link if available
    if (event.directionsLink != null && event.directionsLink!.isNotEmpty) {
      urlString = event.directionsLink!;
    }
    // Otherwise use coordinates if available for more accurate directions
    else if (event.latitude != null && event.longitude != null) {
      urlString = 'https://www.google.com/maps/dir/?api=1&destination=${event.latitude},${event.longitude}';
    } else {
      final encodedLocation = Uri.encodeComponent(event.location);
      urlString = 'https://www.google.com/maps/dir/?api=1&destination=$encodedLocation';
    }
    
    final directionsUrl = Uri.parse(urlString);
    
    if (await canLaunchUrl(directionsUrl)) {
      await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event.dart';
import '../data/models/team.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';
import '../providers/event_provider.dart';
import 'organise_page.dart';

// Event detail page - shows all info about an event
class EventDetailPage extends ConsumerStatefulWidget {
  final Event event; // The event to show details for

  const EventDetailPage({super.key, required this.event});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  String teamName = 'Loading...'; // Stores the team name for display

  @override
  void initState() {
    super.initState();
    // Load team name when page opens
    _loadTeamName();
  }

  // Get the team name from API
  Future<void> _loadTeamName() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final teamsService = TeamsService();
      final teams = await teamsService.fetchTeams(token);

      // Find the team that matches this event

      final team = teams.firstWhere(
        (t) => t.id == widget.event.teamId,
        orElse: () =>
            Team(id: 0, name: 'Unknown Team', membersCount: 0, ownerId: 0),
      );

      setState(() {
        teamName = team.name;
      });
    } catch (e) {
      setState(() {
        teamName = 'Unknown Team';
      });
    }
  }

  // Delete event function
  Future<void> _deleteEvent() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Only delete if user clicked yes
    if (confirm == true) {
      try {
        // Call API to delete event
        final repository = ref.read(eventRepositoryProvider);
        await repository.deleteEvent(widget.event.id);
        // Refresh events list
        ref.invalidate(eventsProvider);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted!'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Date and time
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
            ),
            const SizedBox(height: 12),

            _buildInfoRow(Icons.access_time, 'Time', widget.event.time),
            const SizedBox(height: 12),

            // Location
            _buildInfoRow(Icons.location_on, 'Location', widget.event.location),
            const SizedBox(height: 12),

            // Team
            _buildInfoRow(Icons.group, 'Team', teamName),
            const SizedBox(height: 12),

            // Type
            _buildInfoRow(
              Icons.info,
              'Type',
              widget.event.type == 'upcoming' ? 'Upcoming' : 'Past',
            ),
            const SizedBox(height: 20),

            // Description
            if (widget.event.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Edit and Delete buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrganisePage(event: widget.event),
                        ),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteEvent,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

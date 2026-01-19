import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/stats_card.dart';
import '../providers/event_provider.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';

// Dashboard page - shows overview of teams and events
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int teamCount = 0;
  bool loadingTeams = true;

  @override
  void initState() {
    super.initState();
    // Load team count when page opens
    _loadTeamCount();
  }

  // Get number of teams from API
  Future<void> _loadTeamCount() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final userId = auth.userId;
      final teamsService = TeamsService();
      final allTeams = await teamsService.fetchTeams(token);

      // Filter to only teams user is in
      final userTeams = allTeams
          .where(
            (team) => team.ownerId == userId || team.memberIds.contains(userId),
          )
          .toList();

      setState(() {
        teamCount = userTeams.length;
        loadingTeams = false;
      });
    } catch (e) {
      setState(() {
        loadingTeams = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get events from provider
    final eventsAsync = ref.watch(eventsProvider);
    final upcomingEvents = eventsAsync.whenData(
      (events) => events.where((e) => e.type == 'upcoming').take(3).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allEvents) {
          // Count total events
          final totalEvents = allEvents.length;

          // Get this week's events
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          final thisWeekEvents = allEvents.where((event) {
            return event.date.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                event.date.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
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
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Stats cards
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Grid of stat cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Change number of columns based on screen size
                    int columns = 4;
                    if (constraints.maxWidth < 1200) columns = 3;
                    if (constraints.maxWidth < 900) columns = 2;
                    if (constraints.maxWidth < 600) columns = 1;

                    return GridView.count(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: constraints.maxWidth < 600 ? 3 : 1.2,
                      children: [
                        // Show number of teams
                        StatsCard(
                          title: 'Teams',
                          value: loadingTeams ? '...' : '$teamCount',
                          icon: Icons.group,
                        ),
                        // Show total events
                        StatsCard(
                          title: 'Events',
                          value: '$totalEvents',
                          icon: Icons.calendar_today,
                        ),
                        // shows events scheduled for current week
                        StatsCard(
                          title: 'This Week',
                          value: '$thisWeekEvents',
                          icon: Icons.event_note,
                        ),
                        // counts only future events for planning
                        StatsCard(
                          title: 'Upcoming',
                          value:
                              '${allEvents.where((e) => e.type == 'upcoming').length}',
                          icon: Icons.event_available,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // section displays next 3 upcoming activities
                const Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // loads and displays upcoming events from provider
                ...upcomingEvents.when(
                  loading: () => [const CircularProgressIndicator()],
                  error: (err, stack) => [Text('Error loading events: $err')],
                  data: (events) {
                    // limits display to first 3 events for clean dashboard
                    final displayEvents = events.take(3).toList();

                    if (displayEvents.isEmpty) {
                      return [
                        const Text(
                          'No upcoming events yet. Create one in the Organise page!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ];
                    }

                    // creates list item for each event with formatting
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

  // builds card widget displaying event information
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
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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

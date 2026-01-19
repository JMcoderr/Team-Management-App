import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../data/models/event.dart';
import '../data/models/team.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';
import '../utils/constants.dart';
import 'event_detail_page.dart';

// Events page - shows all events with search and filters
class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  List<Team> userTeams = [];
  String? selectedTeamFilter; // Selected team for filtering
  String searchQuery = '';
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Load teams for filtering when page opens
    _loadTeams();
  }

  // Get teams from API
  Future<void> _loadTeams() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final userId = auth.userId;

      final teamsService = TeamsService();
      final allTeams = await teamsService.fetchTeams(token);

      final filtered = allTeams
          .where(
            (team) => team.ownerId == userId || team.memberIds.contains(userId),
          )
          .toList();

      setState(() {
        userTeams = filtered;
      });
    } catch (e) {
      // Failed to load teams
    }
  }

  String getTeamName(int? teamId) {
    if (teamId == null) return 'No team';
    final team = userTeams.firstWhere(
      (t) => t.id == teamId,
      orElse: () => Team(id: 0, name: 'Unknown', membersCount: 0, ownerId: 0),
    );
    return team.name;
  }

  List<Event> _filterEvents(List<Event> events) {
    var filtered = events;

    // Filter by tab
    if (selectedTab == 1) {
      filtered = filtered.where((e) => e.type == 'upcoming').toList();
    } else if (selectedTab == 2) {
      filtered = filtered.where((e) => e.type == 'past').toList();
    }

    // Filter by team
    if (selectedTeamFilter != null) {
      final teamId = int.tryParse(selectedTeamFilter!);
      if (teamId != null) {
        filtered = filtered.where((e) => e.teamId == teamId).toList();
      }
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (e) =>
                e.title.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Team filter dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedTeamFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter by team',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All teams'),
                    ),
                    ...userTeams.map(
                      (team) => DropdownMenuItem(
                        value: team.id.toString(),
                        child: Text(team.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTeamFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selectedTab = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: selectedTab == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      foregroundColor: selectedTab == 0
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: const Text('All'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selectedTab = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: selectedTab == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      foregroundColor: selectedTab == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: const Text('Upcoming'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selectedTab = 2),
                    style: TextButton.styleFrom(
                      backgroundColor: selectedTab == 2
                          ? AppColors.primary
                          : Colors.transparent,
                      foregroundColor: selectedTab == 2
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: const Text('Past'),
                  ),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (events) {
                final filtered = _filterEvents(events);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No events found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final event = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(event: event),
                            ),
                          );
                        },
                        leading: Icon(
                          event.iconType == 'match'
                              ? Icons.sports_soccer
                              : event.iconType == 'training'
                              ? Icons.fitness_center
                              : Icons.event,
                          color: AppColors.primary,
                        ),
                        title: Text(event.title),
                        subtitle: Text(
                          '${event.date.day}/${event.date.month}/${event.date.year} - ${event.location}\nTeam: ${getTeamName(event.teamId)}',
                        ),
                        trailing: Icon(
                          event.type == 'upcoming'
                              ? Icons.arrow_forward
                              : Icons.check,
                          color: event.type == 'upcoming'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

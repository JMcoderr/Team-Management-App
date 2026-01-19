import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../data/models/event.dart';
import '../data/services/match_service.dart';
import 'matches/organise_match_page.dart';

// Schedule page - shows events and matches in weekly view
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime selectedWeek = DateTime.now(); // Current week being shown
  List<Map<String, dynamic>> matches = []; // Store matches here
  bool loadingMatches = false;

  // Get Monday of the week
  DateTime getStartOfWeek(DateTime date) {
    int daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  // Get all 7 days of the week
  List<DateTime> getWeekDays() {
    DateTime start = getStartOfWeek(selectedWeek);
    List<DateTime> days = [];
    for (int i = 0; i < 7; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  // Go back 7 days
  void previousWeek() {
    setState(() {
      selectedWeek = selectedWeek.subtract(Duration(days: 7));
    });
  }

  // Go forward 7 days
  void nextWeek() {
    setState(() {
      selectedWeek = selectedWeek.add(Duration(days: 7));
    });
  }

  // Load matches from api
  Future<void> loadMatches() async {
    setState(() {
      loadingMatches = true;
    });

    try {
      final matchService = MatchService();
      final allMatches = await matchService.fetchAllMatches();
      final invites = await matchService.fetchMatchInvites();

      // Combine matches with invite status
      List<Map<String, dynamic>> combined = [];
      for (var match in allMatches) {
        // Find invite status for this match
        var invite = invites
            .where((inv) => inv['matchId'] == match['id'])
            .toList();
        String status = 'accepted'; // default
        if (invite.isNotEmpty) {
          status = invite[0]['status'] ?? 'accepted';
        }

        combined.add({...match, 'status': status});
      }

      setState(() {
        matches = combined;
        loadingMatches = false;
      });
    } catch (e) {
      setState(() {
        loadingMatches = false;
      });
    }
  }

  // Delete match
  Future<void> deleteMatch(int matchId) async {
    // Show confirmation first
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Match'),
          content: const Text('Are you sure you want to delete this match?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Call delete api
        final matchService = MatchService();
        await matchService.deleteMatch(matchId: matchId);

        // Remove from list
        setState(() {
          matches.removeWhere((m) => m['id'] == matchId);
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Match deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting match: $e')));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadMatches(); // Load matches when page opens
  }

  @override
  Widget build(BuildContext context) {
    // Get events from provider
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Week navigation bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: previousWeek,
                ),
                Text(
                  '${getStartOfWeek(selectedWeek).day}/${getStartOfWeek(selectedWeek).month} - ${getStartOfWeek(selectedWeek).add(Duration(days: 6)).day}/${getStartOfWeek(selectedWeek).add(Duration(days: 6)).month}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: nextWeek,
                ),
              ],
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (events) {
                // Get the 7 days to show
                List<DateTime> weekDays = getWeekDays();

                return ListView.builder(
                  itemCount: weekDays.length,
                  itemBuilder: (context, index) {
                    DateTime day = weekDays[index];
                    // Day names for display
                    String dayName = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][index];

                    // Find events that match this day
                    List<Event> dayEvents = events.where((event) {
                      return event.date.year == day.year &&
                          event.date.month == day.month &&
                          event.date.day == day.day;
                    }).toList();

                    // Find matches that match this day
                    List<Map<String, dynamic>> dayMatches = matches.where((
                      match,
                    ) {
                      if (match['datetimeStart'] == null) return false;
                      try {
                        DateTime matchDate = DateTime.parse(
                          match['datetimeStart'],
                        );
                        return matchDate.year == day.year &&
                            matchDate.month == day.month &&
                            matchDate.day == day.day;
                      } catch (e) {
                        return false;
                      }
                    }).toList();

                    // Count total items
                    int totalItems = dayEvents.length + dayMatches.length;

                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$dayName ${day.day}/${day.month}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (totalItems > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$totalItems',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (totalItems == 0)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No events or matches',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            Column(
                              children: [
                                // Show events first
                                ...dayEvents.map((event) {
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.event,
                                      color: Colors.blue,
                                    ),
                                    title: Text(event.title),
                                    subtitle: Text(
                                      '${event.time} - ${event.location}',
                                    ),
                                  );
                                }),
                                // Show matches
                                ...dayMatches.map((match) {
                                  // Get time from datetime
                                  String matchTime = '';
                                  try {
                                    DateTime dt = DateTime.parse(
                                      match['datetimeStart'],
                                    );
                                    matchTime =
                                        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                  } catch (e) {
                                    matchTime = 'N/A';
                                  }

                                  // Get status
                                  String status = match['status'] ?? 'accepted';
                                  Color statusColor = status == 'pending'
                                      ? Colors.orange
                                      : Colors.green;

                                  return ListTile(
                                    leading: const Icon(
                                      Icons.sports_soccer,
                                      color: Colors.red,
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            match['title'] ?? 'Match',
                                          ),
                                        ),
                                        // Status badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(matchTime),
                                    trailing: SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Edit button
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              // Go to edit match page
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const OrganiseMatchPage(),
                                                ),
                                              ).then((_) => loadMatches());
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          // Delete button
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              deleteMatch(match['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
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

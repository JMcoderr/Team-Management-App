import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../data/models/event.dart';

// Schedule page - shows events in weekly view
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime selectedWeek = DateTime.now(); // Current week being shown

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
                                if (dayEvents.isNotEmpty)
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
                                      '${dayEvents.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (dayEvents.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No events',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
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
                            }).toList(),
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

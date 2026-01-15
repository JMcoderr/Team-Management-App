import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../data/models/event.dart';

// showing your schedule as a week planner
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  String? selectedTeam; // which team is selected in dropdown (null = all teams)
  DateTime selectedWeek = DateTime.now(); // current week we're viewing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
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

          // week navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Text(
                  _getWeekRange(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedWeek = selectedWeek.add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),

          // weekly planner view
          Expanded(
            child: _buildWeeklyPlanner(),
          ),
        ],
          ),
        ),
      ),
    );
  }

  // getting week range text
  String _getWeekRange() {
    final startOfWeek = _getStartOfWeek(selectedWeek);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM').format(endOfWeek)}';
  }

  // getting start of week (monday)
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  // building weekly planner view
  Widget _buildWeeklyPlanner() {
    final eventsData = ref.watch(eventsProvider);

    return eventsData.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Something went wrong...', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(eventsProvider),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
      data: (events) {
        // filter by team
        final filteredEvents = selectedTeam == null
            ? events
            : events.where((event) => true).toList(); // TODO: filter by team when available

        // group events by day of week
        final startOfWeek = _getStartOfWeek(selectedWeek);
        final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(eventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weekDays.length,
            itemBuilder: (context, i) {
              final day = weekDays[i];
              final dayEvents = filteredEvents.where((event) {
                return event.date.year == day.year &&
                    event.date.month == day.month &&
                    event.date.day == day.day;
              }).toList();

              return _buildDaySection(day, dayEvents);
            },
          ),
        );
      },
    );
  }

  // building each day section
  Widget _buildDaySection(DateTime day, List events) {
    final isToday = DateTime.now().day == day.day &&
        DateTime.now().month == day.month &&
        DateTime.now().year == day.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? Colors.blue : Colors.grey[300]!,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // day header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE').format(day), // day name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.blue : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMM').format(day), // date
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (events.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // events for this day
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No events',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            )
          else
            ...events.map((event) {
              // picking icon
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

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: InkWell(
                  onTap: () => _showEventDetails(context, event, ref),
                  child: Row(
                    children: [
                      // icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      // event info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  event.time,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // showing event details when clicked
  void _showEventDetails(BuildContext context, Event event, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(event.description),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy').format(event.date)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(event.time),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editEvent(context, event, ref);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(context, event, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // confirming before delete
  void _confirmDelete(BuildContext context, Event event, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event.id, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // deleting event
  Future<void> _deleteEvent(int id, WidgetRef ref) async {
    try {
      final repository = ref.read(eventRepositoryProvider);
      await repository.deleteEvent(id);
      ref.invalidate(eventsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // editing event
  void _editEvent(BuildContext context, Event event, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _EditEventDialog(event: event, ref: ref),
    );
  }
}

// dialog for editing event
class _EditEventDialog extends StatefulWidget {
  final Event event;
  final WidgetRef ref;

  const _EditEventDialog({required this.event, required this.ref});

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // pre-filling with current values
    titleController = TextEditingController(text: widget.event.title);
    locationController = TextEditingController(text: widget.event.location);
    descriptionController = TextEditingController(text: widget.event.description);
    selectedDate = widget.event.date;
    
    // parsing time
    final timeParts = widget.event.time.split(':');
    selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1].split(' ')[0]),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(selectedTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveChanges,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  // saving edited event
  Future<void> _saveChanges() async {
    if (titleController.text.isEmpty || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and location are required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // creating updated event
      final updatedEvent = widget.event.copyWith(
        title: titleController.text,
        location: locationController.text,
        description: descriptionController.text,
        date: selectedDate,
        time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
      );

      final repository = widget.ref.read(eventRepositoryProvider);
      await repository.updateEvent(widget.event.id, updatedEvent);
      widget.ref.invalidate(eventsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

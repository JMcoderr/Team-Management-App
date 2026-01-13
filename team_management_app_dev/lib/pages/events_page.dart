import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/event_provider.dart';

// showing all events with filter options
class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // searchbar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // filter buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Upcoming', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Past', 2),
              ],
            ),
          ),

          // list of events
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: add event form
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Event - Coming Soon!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // creating filter buttons
  Widget _buildFilterChip(String label, int index) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final bool isSelected = selectedFilter == index;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // change selected filter
        ref.read(selectedFilterProvider.notifier).update(index);
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  // showing events in a list
  Widget _buildEventList() {
    final eventsData = ref.watch(filteredEventsProvider);

    return eventsData.when(
      // when loading
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading events...'),
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
              'Something went wrong',
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

      // Success state 
      data: (events) {
        // Show empty state if no events match
        if (events.isEmpty) {
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
                  ref.watch(searchQueryProvider).isNotEmpty
                      ? 'Try a different search'
                      : 'Check back later!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // showing events
        return RefreshIndicator(
          onRefresh: () async {
            // refresh when pulled down
            ref.invalidate(eventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
              return EventCard(
                title: event.title,
                date: '${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}/${event.date.year}',
                time: event.time,
                location: event.location,
                icon: _getIconForType(event.iconType),
                iconColor: event.type == 'upcoming' ? Colors.blue : Colors.grey,
                onTap: () => _showEventDetails(event),
              );
            },
          ),
        );
      },
    );
  }

  // getting icon for event type
  IconData _getIconForType(String iconType) {
    switch (iconType) {
      case 'training':
        return Icons.fitness_center;
      case 'meeting':
        return Icons.meeting_room;
      case 'match':
        return Icons.sports_soccer;
      default:
        return Icons.event_note;
    }
  }

  // showing event details when clicked
  void _showEventDetails(event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIconForType(event.iconType), color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${event.date.day}/${event.date.month}/${event.date.year}'),
              ],
            ),
            const SizedBox(height: 8),
            // time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(event.time),
              ],
            ),
            const SizedBox(height: 8),
            // location
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location)),
              ],
            ),
            const SizedBox(height: 16),
            // description
            if (event.description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(event.description),
              ),
          ],
        ),
        actions: [
          // delete button
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(event);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          // edit button
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _editEvent(event);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          // close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // confirming delete
  void _confirmDelete(event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // deleting event
  Future<void> _deleteEvent(event) async {
    try {
      final repository = ref.read(eventRepositoryProvider);
      await repository.deleteEvent(event.id);
      
      // refresh list
      ref.invalidate(eventsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event deleted! (Local mode - login needed to sync)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // opening edit dialog
  void _editEvent(event) {
    showDialog(
      context: context,
      builder: (context) => _EditEventDialog(event: event),
    );
  }
}

// edit event dialog
class _EditEventDialog extends ConsumerStatefulWidget {
  final dynamic event;
  
  const _EditEventDialog({required this.event});

  @override
  ConsumerState<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends ConsumerState<_EditEventDialog> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // pre-fill with existing data
    titleController = TextEditingController(text: widget.event.title);
    locationController = TextEditingController(text: widget.event.location);
    descriptionController = TextEditingController(text: widget.event.description);
    selectedDate = widget.event.date;
    selectedTime = TimeOfDay(
      hour: widget.event.date.hour,
      minute: widget.event.date.minute,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
            ),
            const SizedBox(height: 16),
            
            // time picker
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            
            // location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            
            // description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
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
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  // saving changes
  Future<void> _saveChanges() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final repository = ref.read(eventRepositoryProvider);
      
      // combine date and time
      final eventDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      
      // create updated event
      final updatedEvent = widget.event.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDateTime,
        time: selectedTime.format(context),
        location: locationController.text.trim(),
        type: eventDateTime.isAfter(DateTime.now()) ? 'upcoming' : 'past',
      );
      
      await repository.updateEvent(widget.event.id, updatedEvent);
      
      // refresh
      ref.invalidate(eventsProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event updated! (Local mode - login needed to sync)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

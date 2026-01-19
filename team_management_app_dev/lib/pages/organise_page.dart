import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/team.dart';
import '../data/models/event.dart';
import '../providers/event_provider.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';

// Organise page - create or edit events
class OrganisePage extends ConsumerStatefulWidget {
  final Event? event; // If editing, this will have the event data

  const OrganisePage({super.key, this.event});

  @override
  ConsumerState<OrganisePage> createState() => _OrganisePageState();
}

class _OrganisePageState extends ConsumerState<OrganisePage> {
  // Text controllers for input fields
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  // Date and time variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Team selection
  int? selectedTeamId;
  List<Team> userTeams = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Load teams and setup form when page opens
    _loadTeams();
    _initializeForm();
  }

  // Fill in form if editing existing event
  void _initializeForm() {
    if (widget.event != null) {
      titleController.text = widget.event!.title;
      locationController.text = widget.event!.location;
      descriptionController.text = widget.event!.description;
      selectedDate = widget.event!.date;
      selectedTime = TimeOfDay(
        hour: int.parse(widget.event!.time.split(':')[0]),
        minute: int.parse(widget.event!.time.split(':')[1]),
      );
      selectedTeamId = widget.event!.teamId;
    }
  }

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
        if (userTeams.isNotEmpty) {
          selectedTeamId = userTeams.first.id;
        }
      });
    } catch (e) {
      // Failed to load teams
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (titleController.text.isEmpty || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and location')),
      );
      return;
    }

    if (selectedTeamId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a team')));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final eventDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final eventData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'datetimeStart': eventDateTime.toIso8601String(),
        'datetimeEnd': eventDateTime
            .add(const Duration(hours: 2))
            .toIso8601String(),
        'location': locationController.text.trim(),
        'teamId': selectedTeamId!,
      };

      final repository = ref.read(eventRepositoryProvider);

      Event createdEvent;
      if (widget.event != null) {
        // Update existing event
        createdEvent = await repository.updateEvent(
          widget.event!.id,
          eventData,
        );
        // Save location locally
        eventLocations[widget.event!.id] = locationController.text.trim();
      } else {
        // Create new event
        createdEvent = await repository.createEvent(eventData);
        // Save location locally
        eventLocations[createdEvent.id] = locationController.text.trim();
      }

      ref.invalidate(eventsProvider);

      if (!mounted) return;

      // Pop back if editing before setState
      if (widget.event != null) {
        Navigator.pop(context);
        return;
      }

      // Only clear form if creating new event and still mounted
      setState(() {
        loading = false;
        titleController.clear();
        descriptionController.clear();
        locationController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Create Event'),
        backgroundColor: Colors.blue,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Team selector
                  DropdownButtonFormField<int>(
                    initialValue: selectedTeamId,
                    decoration: const InputDecoration(
                      labelText: 'Select Team',
                      border: OutlineInputBorder(),
                    ),
                    items: userTeams.map((team) {
                      return DropdownMenuItem<int>(
                        value: team.id,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeamId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time picker
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _pickTime,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        widget.event != null ? 'Update Event' : 'Create Event',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

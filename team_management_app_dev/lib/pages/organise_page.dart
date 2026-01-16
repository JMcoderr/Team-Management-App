import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/event.dart';
import '../data/models/team.dart';
import '../providers/event_provider.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';

// page for creating new events/matches
class OrganisePage extends ConsumerStatefulWidget {
  const OrganisePage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganisePage> createState() => _OrganisePageState();
}

class _OrganisePageState extends ConsumerState<OrganisePage> {
  // controllers for text fields (like variables that remember what user typed)
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final googleMapsLinkController = TextEditingController();
  final directionsLinkController = TextEditingController();
  
  // date and time variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  
  // team selection (for API v2)
  int? selectedTeamId;
  List<Team> userTeams = []; // teams where user is member
  bool loadingTeams = true;
  
  bool isLoading = false; // to show spinner when saving

  @override
  void initState() {
    super.initState();
    // load teams when page opens
    _loadUserTeams();
  }

  // get teams from api
  Future<void> _loadUserTeams() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final userId = auth.userId;
      
      // fetch all teams
      final teamsService = TeamsService();
      final allTeams = await teamsService.fetchTeams(token);
      
      // only show teams where user is owner or member
      final filtered = allTeams.where((team) => 
        team.ownerId == userId || team.memberIds.contains(userId)
      ).toList();
      
      setState(() {
        userTeams = filtered;
        loadingTeams = false;
      });
    } catch (e) {
      print('error loading teams: $e');
      setState(() {
        loadingTeams = false;
      });
    }
  }

  @override
  void dispose() {
    // cleanup when page closes 
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    googleMapsLinkController.dispose();
    directionsLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 32),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title field
            const Text(
              'Event Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Match vs RedOpps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // team selection dropdown
            const Text(
              'Team',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: loadingTeams 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButton<int?>(
                value: selectedTeamId,
                isExpanded: true,
                underline: Container(),
                hint: const Text('Select a team'),
                items: [
                  // no team option
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No team selected'),
                  ),
                  // real teams from api
                  ...userTeams.map((team) {
                    return DropdownMenuItem(
                      value: team.id,
                      child: Text(team.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTeamId = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // date picker
            const Text(
              'Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // time picker
            const Text(
              'Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickTime(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // location field
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Sports Hall A',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Google Maps place link field
            const Text(
              'Google Maps Place Link (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: googleMapsLinkController,
              decoration: InputDecoration(
                hintText: 'e.g. https://maps.app.goo.gl/xxxxx',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.map),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Google Maps directions link field
            const Text(
              'Google Maps Directions Link (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: directionsLinkController,
              decoration: InputDecoration(
                hintText: 'e.g. https://maps.app.goo.gl/xxxxx',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.directions),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // description field
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add details about the event...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // create button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Event',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  // opening date picker
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // opening time picker
  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // saving the event
  Future<void> _createEvent() async {
    // check if title is empty
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    if (locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // get the repository
      final repository = ref.read(eventRepositoryProvider);
      
      // combining date and time
      final eventDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      
      // get location coordinates if preset was selected
      double? lat;
      double? lng;
      final locationText = locationController.text.trim();
      
      // create the event object
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch, // temp id
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDateTime,
        time: selectedTime.format(context),
        location: locationText,
        type: eventDateTime.isAfter(DateTime.now()) ? 'upcoming' : 'past',
        teamId: selectedTeamId ?? 1,  // Use selected team or default to 1
        latitude: lat,
        longitude: lng,
        googleMapsLink: googleMapsLinkController.text.trim().isEmpty 
            ? null 
            : googleMapsLinkController.text.trim(),
        directionsLink: directionsLinkController.text.trim().isEmpty 
            ? null 
            : directionsLinkController.text.trim(),
      );
      
      // save it
      await repository.createEvent(newEvent);
      
      // refresh the events list and routeplanner
      ref.invalidate(eventsProvider);
      ref.invalidate(upcomingEventsProvider);
      
      // show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // clear the form
        titleController.clear();
        locationController.clear();
        descriptionController.clear();
        googleMapsLinkController.clear();
        directionsLinkController.clear();
        setState(() {
          selectedDate = DateTime.now();
          selectedTime = TimeOfDay.now();
          selectedTeamId = null;
        });
      }
    } catch (e) {
      // if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

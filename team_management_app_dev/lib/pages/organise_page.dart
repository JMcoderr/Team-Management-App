import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/event.dart';
import '../providers/event_provider.dart';

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
  
  // date and time variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  
  bool isLoading = false; // to show spinner when saving

  @override
  void dispose() {
    // cleanup when page closes (like turning off lights when leaving a room)
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
      
      // create the event object
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch, // temp id
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDateTime,
        time: selectedTime.format(context),
        location: locationController.text.trim(),
        type: eventDateTime.isAfter(DateTime.now()) ? 'upcoming' : 'past',
      );
      
      // save it
      await repository.createEvent(newEvent);
      
      // refresh the events list
      ref.invalidate(eventsProvider);
      
      // show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event created! (Local mode - login needed to save permanently)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // clear the form
        titleController.clear();
        locationController.clear();
        descriptionController.clear();
        setState(() {
          selectedDate = DateTime.now();
          selectedTime = TimeOfDay.now();
        });
      }
    } catch (e) {
      // if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

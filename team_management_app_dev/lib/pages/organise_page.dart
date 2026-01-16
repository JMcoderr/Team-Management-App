import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/event.dart';
import '../data/models/team.dart';
import '../providers/event_provider.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';
import '../utils/constants.dart';

// page for creating new events
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event_available, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            const Text('Organise Event'),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Icon(Icons.event_available, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create an Event',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Schedule training sessions, meetings, or other events',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // form card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title field
                      _buildLabel('Event Title'),
                      TextField(
                        controller: titleController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. Training Session',
                          icon: Icons.event,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // team dropdown
                      _buildLabel('Team'),
                      loadingTeams
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<int?>(
                              value: selectedTeamId,
                              decoration: _buildInputDecoration(
                                hint: 'Select team (optional)',
                                icon: Icons.group,
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('No team'),
                                ),
                                ...userTeams.map((team) {
                                  return DropdownMenuItem<int?>(
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
                      const SizedBox(height: AppSpacing.md),

                      // date and time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Date'),
                                InkWell(
                                  onTap: () => _pickDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      border: Border.all(color: AppColors.divider),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(selectedDate),
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Time'),
                                InkWell(
                                  onTap: () => _pickTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      border: Border.all(color: AppColors.divider),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time, size: 20, color: AppColors.primary),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          selectedTime.format(context),
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // location
                      _buildLabel('Location'),
                      TextField(
                        controller: locationController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. Sportpark Amsterdam',
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // google maps links
                      _buildLabel('Google Maps Place Link (Optional)'),
                      TextField(
                        controller: googleMapsLinkController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. https://maps.app.goo.gl/xxxxx',
                          icon: Icons.map,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildLabel('Google Maps Directions Link (Optional)'),
                      TextField(
                        controller: directionsLinkController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. https://maps.app.goo.gl/xxxxx',
                          icon: Icons.directions,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // description
                      _buildLabel('Description (Optional)'),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          hint: 'Add event details, notes, etc.',
                          icon: Icons.notes,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // create button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _createEvent,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: Text(
                            isLoading ? 'Creating...' : 'Create Event',
                            style: AppTextStyles.button,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            elevation: AppSpacing.elevationSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
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
            backgroundColor: AppColors.success,
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

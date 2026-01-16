import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/event.dart';
import '../data/models/team.dart';
import '../providers/event_provider.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';
import '../utils/constants.dart';

// page for creating matches specifically
class OrganiseMatchPage extends ConsumerStatefulWidget {
  const OrganiseMatchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganiseMatchPage> createState() => _OrganiseMatchPageState();
}

class _OrganiseMatchPageState extends ConsumerState<OrganiseMatchPage> {
  // controllers for text fields
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final googleMapsLinkController = TextEditingController();
  final directionsLinkController = TextEditingController();
  final opponentController = TextEditingController();
  
  // date and time stuff
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  
  // team selection
  int? selectedTeamId;
  List<Team> userTeams = [];
  bool loadingTeams = true;
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserTeams();
  }

  // get teams from api
  Future<void> _loadUserTeams() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final userId = auth.userId;
      
      final teamsService = TeamsService();
      final allTeams = await teamsService.fetchTeams(token);
      
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
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    googleMapsLinkController.dispose();
    directionsLinkController.dispose();
    opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.sports_soccer, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            const Text('Organise Match'),
          ],
        ),
        backgroundColor: AppColors.match,
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
                      colors: [AppColors.match, AppColors.match.withOpacity(0.8)],
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
                        child: Icon(Icons.sports_soccer, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create a Match',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Schedule a match for your team',
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
                      // match title
                      _buildLabel('Match Title'),
                      TextField(
                        controller: titleController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. vs Ajax Academy',
                          icon: Icons.sports_soccer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // opponent
                      _buildLabel('Opponent Team'),
                      TextField(
                        controller: opponentController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g. Ajax Academy',
                          icon: Icons.group,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // team dropdown
                      _buildLabel('Your Team'),
                      loadingTeams
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<int>(
                              value: selectedTeamId,
                              decoration: _buildInputDecoration(
                                hint: 'Select team',
                                icon: Icons.group_outlined,
                              ),
                              items: userTeams.map((team) {
                                return DropdownMenuItem(
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
                                  onTap: () => _pickDate(),
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
                                  onTap: () => _pickTime(),
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
                          hint: 'Add match details, notes, etc.',
                          icon: Icons.notes,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // create button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _createMatch,
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
                            isLoading ? 'Creating...' : 'Create Match',
                            style: AppTextStyles.button,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.match,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
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

  Future<void> _createMatch() async {
    // validate stuff
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please add a match title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please select a team'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please add a location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

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

      final newMatch = Event(
        id: DateTime.now().millisecondsSinceEpoch,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDateTime,
        time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        location: locationController.text.trim(),
        type: eventDateTime.isAfter(DateTime.now()) ? 'upcoming' : 'past',
        iconType: 'soccer', // match icon
        teamId: selectedTeamId,
        googleMapsLink: googleMapsLinkController.text.trim().isEmpty 
            ? null 
            : googleMapsLinkController.text.trim(),
        directionsLink: directionsLinkController.text.trim().isEmpty 
            ? null 
            : directionsLinkController.text.trim(),
      );
      
      await repository.createEvent(newMatch);
      
      // refresh
      ref.invalidate(eventsProvider);
      ref.invalidate(upcomingEventsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Match created successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // clear form
        titleController.clear();
        locationController.clear();
        descriptionController.clear();
        opponentController.clear();
        googleMapsLinkController.clear();
        directionsLinkController.clear();
        setState(() {
          selectedDate = DateTime.now();
          selectedTime = TimeOfDay.now();
          selectedTeamId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create match: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

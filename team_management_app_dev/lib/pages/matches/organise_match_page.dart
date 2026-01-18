import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/team.dart';
import '../../data/services/teams_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/match_service.dart';
import '../../utils/constants.dart';

// page for creating matches specifically
class OrganiseMatchPage extends StatefulWidget {
  const OrganiseMatchPage({Key? key}) : super(key: key);

  @override
  State<OrganiseMatchPage> createState() => _OrganiseMatchPageState();
}

class _OrganiseMatchPageState extends State<OrganiseMatchPage> {
  // controllers for text fields
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final instructionsController = TextEditingController();

  // date and time stuff
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // team selection
  int? selectedTeamId;
  int? selectedOpponentTeamId;

  // state variables
  List<Team> userTeams = [];
  bool isLoadingTeams = true;

  List<Team> opponentTeams = [];
  bool isLoadingOpponentTeams = true;

  // updated when teams are loaded or refreshed
  late Future<List<Team>> teamsFuture;
  late Future<List<Team>> allTeamsFuture;

  final teamsService = TeamsService();
  final auth = AuthService();

  // create match function
  Future<void> _createMatch() async {
    // check if teams are selected
    if (selectedTeamId == null || selectedOpponentTeamId == null || selectedTeamId == selectedOpponentTeamId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both teams.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final endDateTime = startDateTime.add(const Duration(hours: 2));

      // Turn to ISO string for the API
      final datetimeStart = startDateTime.toIso8601String();
      final datetimeEnd = endDateTime.toIso8601String();


      await MatchService().createMatch(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        datetimeStart: datetimeStart,
        datetimeEnd: datetimeEnd,
        latitude: 0.0, // Placeholder, TODO: use geocoding package
        longitude: 0.0, // ^^
        teamId: selectedTeamId!,
        opponentTeamId: selectedOpponentTeamId!,
        instructions: instructionsController.text.trim(),
      );

      // Feedback for users
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create match: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTeams();
    loadOpponentTeams();
  }

  // fetches teams from API and filters
  void loadTeams() {
    final token = auth.token;
    final loggedInUserId = auth.userId;

    setState(() {
      teamsFuture = teamsService.fetchTeams(token).then((teams) {
        // filters teams to only show teams owned by logged in user
        final filtered = teams.where((team) {
          final isOwner = team.ownerId == loggedInUserId;
          return isOwner;
        }).toList();
        return filtered;
      });
    });
  }

  // fetches all other teams for opponent selection
  void loadOpponentTeams() {
    final token = auth.token;

    setState(() {
      allTeamsFuture = teamsService.fetchTeams(token);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            const Text('Organise Match'),
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
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 32,
                          color: Colors.white,
                        ),
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
                                color: Colors.white.withValues(alpha: 0.9),
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
                          icon: Icons.emoji_events,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // team dropdown
                      _buildLabel('Your Team'),
                      FutureBuilder<List<Team>>(
                        future: teamsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error loading teams');
                          }

                          final teams = snapshot.data ?? [];

                          return DropdownButtonFormField<int?>(
                            value: selectedTeamId,
                            decoration: _buildInputDecoration(
                              hint: 'Select team',
                              icon: Icons.group_outlined,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('No team'),
                              ),
                              ...teams.map((team) => DropdownMenuItem<int?>(
                                    value: team.id,
                                    child: Text(team.name),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTeamId = value;
                              });
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),

                      // opponent team dropdown
                      _buildLabel('Opponent Team'),
                      FutureBuilder<List<Team>>(
                        future: allTeamsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error loading teams');
                          }

                          final teams = snapshot.data ?? [];

                          return DropdownButtonFormField<int?>(
                            value: selectedOpponentTeamId,
                            decoration: _buildInputDecoration(
                              hint: 'Select opponent team',
                              icon: Icons.group_outlined,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Select opponent'),
                              ),
                              ...teams.map((team) => DropdownMenuItem<int?>(
                                    value: team.id,
                                    child: Text(team.name),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedOpponentTeamId = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // instructions
                      _buildLabel('Match Instructions (Optional)'),
                      TextField(
                        controller: instructionsController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          hint: 'Add special instructions, meeting point, etc.',
                          icon: Icons.info,
                        ),
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
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(selectedDate),
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
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
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

                      // action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _createMatch();
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Create Match'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
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

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
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

}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/team.dart';
import '../../data/services/teams_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/match_service.dart';
import '../../utils/constants.dart';

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
    // fetch teams user is part of

    // fetch all teams for invites

  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
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
                        AppColors.primary.withOpacity(0.8),
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
                          color: Colors.white.withOpacity(0.2),
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
                          icon: Icons.emoji_events,
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
                          : DropdownButtonFormField<int?>(
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

                      // create button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 56,
                      //   child: ElevatedButton.icon(
                      //     onPressed: isLoading ? null : _createMatch,
                      //     icon: isLoading
                      //         ? const SizedBox(
                      //             width: 20,
                      //             height: 20,
                      //             child: CircularProgressIndicator(
                      //               strokeWidth: 2,
                      //               color: Colors.white,
                      //             ),
                      //           )
                      //         : const Icon(Icons.add),
                      //     label: Text(
                      //       isLoading ? 'Creating...' : 'Create Match',
                      //       style: AppTextStyles.button,
                      //     ),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: AppColors.primary,
                      //       foregroundColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(
                      //           AppSpacing.radiusMd,
                      //         ),
                      //       ),
                      //       elevation: AppSpacing.elevationSm,
                      //     ),
                      //   ),
                      // ),
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

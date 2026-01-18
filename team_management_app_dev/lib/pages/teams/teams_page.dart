import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';
import 'package:team_management_app_dev/data/models/team.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_widgets.dart';
import 'create_team_page.dart';
import 'edit_team_page.dart';
import 'scan_qr_page.dart';
import 'show_qr_page.dart';

// TeamsPage shows all teams the user is part of
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  late Future<List<Team>> teamsFuture;
  final teamsService = TeamsService();
  final auth = AuthService();
  final Set<int> expandedTeams = {};

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    final token = auth.token;
    final loggedInUserId = auth.userId;

    setState(() {
      teamsFuture = teamsService.fetchTeams(token).then((teams) {
        // Filter teams where user is owner or a member
        final filtered = teams.where((team) {
          final isOwner = team.ownerId == loggedInUserId;
          final isMember = team.memberIds.contains(loggedInUserId);
          return isOwner || isMember;
        }).toList();
        return filtered;
      });
    });
  }

  // Check if user is team owner
  bool _isUserTeamOwner(Team team) {
    final loggedInUserId = auth.userId;
    return team.ownerId == loggedInUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Teams list
            Expanded(
              child: FutureBuilder<List<Team>>(
                future: teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => const CardSkeleton(),
                    );
                  }

                  // Show error if any happen
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed loading teams: ${snapshot.error}',
                        style: AppTextStyles.body.copyWith(color: Colors.red),
                      ),
                    );
                  }

                  final teams = snapshot.data!;

                  // Empty state
                  if (teams.isEmpty) {
                    return EmptyState(
                      icon: Icons.group,
                      title: 'No teams yet',
                      message:
                          'Create your first team or get invited to one and they will appear here!',
                    );
                  }

                  // Display teams
                  return Material(
                    child: ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final teamId = team.id.toString();
                        final isExpanded = expandedTeams.contains(team.id);

                        // Card for each team
                        return Material(
                          child: CustomCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with team info and edit button
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                      ),
                                      child: Icon(
                                        team.icon != null
                                            ? Icons.calendar_today
                                            : Icons.group,
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(team.name, style: AppTextStyles.h5),
                                          const SizedBox(height: AppSpacing.xxs),
                                          if (team.description != null && team.description!.isNotEmpty)
                                            Text(
                                              team.description!,
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    // Show edit button only if user is team owner
                                      // Edit team button
                                      if (_isUserTeamOwner(team))
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditTeamPage(teamId: teamId),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit),
                                        color: AppColors.primary,
                                        tooltip: 'Edit team',
                                      ),
                                      // Invite a member
                                      if (_isUserTeamOwner(team)) 
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ScanCodePage(teamId: teamId),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.add),
                                        color: AppColors.primary,
                                        tooltip: 'Invite member',
                                      ),
                                      // Delete team button
                                      if (_isUserTeamOwner(team))
                                      IconButton(
                                        onPressed: () {
                                          teamsService.deleteTeam(team.id).then((_) {
                                            // Show success message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Team deleted successfully!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }).catchError((e) {
                                            // Show error message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to delete team: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          });
                                          // Reload teams
                                          _loadTeams();
                                        },
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                        tooltip: 'Delete team',
                                      ),
                                      // Leave team button
                                      if (!_isUserTeamOwner(team))
                                      IconButton(
                                        onPressed: () {
                                          teamsService.leaveTeam(team.id).then((_) {
                                            // Show success message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Team left successfully! Refresh to see changes.'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }).catchError((e) {
                                            // Show error message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to leave team: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.remove_circle),
                                        color: Colors.red,
                                        tooltip: 'Leave team',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Members list on click
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            expandedTeams.remove(team.id);
                                          } else {
                                            expandedTeams.add(team.id);
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            Icon(
                                              Icons.people,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            Text(
                                              '${team.membersCount} members',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Expanded members list
                                    if (isExpanded && team.members != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: AppSpacing.sm,
                                          left: AppSpacing.md,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: team.members!
                                              .map((member) {
                                                final memberId = member['id'] as int;
                                                final memberName = member['name'] as String;
                                                final isOwner = memberId == team.ownerId;
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: AppSpacing.xs,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isOwner
                                                          ? AppColors.primary.withValues(alpha: 0.05)
                                                          : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(
                                                        AppSpacing.radiusSm,
                                                      ),
                                                      border: isOwner
                                                          ? Border.all(
                                                              color: AppColors.primary.withValues(alpha: 0.2),
                                                            )
                                                          : null,
                                                    ),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: AppSpacing.sm,
                                                      vertical: AppSpacing.xs,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.person,
                                                          size: 16,
                                                          color: isOwner
                                                              ? AppColors.primary
                                                              : AppColors.textSecondary,
                                                        ),
                                                        const SizedBox(width: AppSpacing.xs),
                                                        Expanded(
                                                          child: Text(
                                                            memberName,
                                                            style: AppTextStyles.bodySmall.copyWith(
                                                              color: isOwner
                                                                  ? AppColors.primary
                                                                  : AppColors.textPrimary,
                                                              fontWeight: isOwner
                                                                  ? FontWeight.w600
                                                                  : FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isOwner)
                                                          Chip(
                                                            label: const Text(
                                                              'Team Owner',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                AppColors.primary.withValues(alpha: 0.2),
                                                            labelPadding: const EdgeInsets.symmetric(
                                                              horizontal: AppSpacing.xs,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),


            // Create Team button
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTeamPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              color: AppColors.primary,
              tooltip: 'Create new team',
            ),

            // Show QR button
            IconButton(
              onPressed: () {
                final userId = auth.userId.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowQrPage(userId: userId),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              color: AppColors.primary,
              tooltip: 'Show QR Code',
            ),
            
            const SizedBox(height: AppSpacing.sm),

            // Scan QR button

          ],
        ),
      ),
    );
  }
}

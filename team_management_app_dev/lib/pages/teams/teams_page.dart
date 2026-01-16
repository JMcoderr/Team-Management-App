import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';
import 'package:team_management_app_dev/data/models/team.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_widgets.dart';
import 'create_team_page.dart';
import 'edit_team_page.dart';

// TeamsPage shows all teams the user is part of
class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teamsService = TeamsService();
    final auth = AuthService();
    final token = auth.token;
    final loggedInUserId = auth.userId;

    // Fetch all teams and filter by user membership
    final Future<List<Team>> teamsFuture = teamsService.fetchTeams(token).then((teams) {
      // Filter teams where user is owner or a member
      return teams
          .where((team) =>
              team.ownerId == loggedInUserId ||
              team.memberIds.contains(loggedInUserId))
          .toList();
    });

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
            // Invitations box (placeholder - not implemented yet)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'You have 2 team invitations',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement invitations page
                      },
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: AppColors.error),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Error loading teams',
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${snapshot.error}',
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final teams = snapshot.data!;

                  // Empty state
                  if (teams.isEmpty) {
                    return EmptyState(
                      icon: Icons.group,
                      title: 'No teams yet',
                      message: 'Create your first team to get started!\nInvite members and organize events together.',
                      buttonText: 'Create Team',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTeamPage(),
                          ),
                        );
                      },
                    );
                  }

                  // Display teams with animation
                  return ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final teamId = team.id.toString();
                      
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: CustomCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          onTap: () {
                            // Could navigate to team details page
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Icon(
                                  team.icon != null ? Icons.calendar_today : Icons.group,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name,
                                      style: AppTextStyles.h5,
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: AppSpacing.xxs),
                                        Text(
                                          '${team.membersCount} members',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTeamPage(teamId: teamId),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                color: AppColors.primary,
                                tooltip: 'Edit team',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Create Team button
            AnimatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTeamPage(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: AppSpacing.xs),
                  Text('Create New Team', style: AppTextStyles.button),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

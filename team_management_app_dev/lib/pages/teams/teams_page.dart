import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';
import 'package:team_management_app_dev/data/models/team.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';
import 'create_team_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teamsService = TeamsService();
    final auth = AuthService();
    final token = auth.token;
    final loggedInUserId = auth.userId;


    // Fetch all teams
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Invitations box
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
                      onPressed: () {},
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final teams = snapshot.data!;

                  // Check if no teams
                  if (teams.isEmpty) {
                    return Center(
                      child: Text('You are not part of any teams.'),
                    );
                  }

                  // Add teams to list
                  return ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(team.icon != null
                              ? Icons.calendar_today
                              : Icons.group),
                          title: Text(team.name),
                          subtitle: Text('${team.membersCount} members'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Create Team button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return const CreateTeamPage();
                }));
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Team'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}



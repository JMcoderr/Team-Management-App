import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';
import 'package:team_management_app_dev/data/services/match_service.dart';

// InvitationsPage displays all invitations the user has received
class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  late Future<List<dynamic>> invitationsFuture;

  final teamsService = TeamsService();
  final matchService = MatchService();
  final auth = AuthService();

  @override
  void initState() {
    super.initState();
    invitationsFuture = MatchService().getAllInviteDetails(auth.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MatchService().getAllInviteDetails(auth.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // make empty list if no invites
          final invites = snapshot.data ?? [];

          if (invites.isEmpty) {
            return const Center(child: Text('No pending invites'));
          }

          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              final match = invite['match'];

              return ListTile(
                title: Text(match['title']),
                subtitle: Text(match['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        matchService.acceptMatchInvite(inviteId: invite['inviteId'] as int);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        matchService.declineMatchInvite(inviteId: invite['inviteId'] as int); 
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/team_card.dart';
import '../providers/team_provider.dart';

// Rosters page - shows list of all teams
class RostersPage extends ConsumerStatefulWidget {
  const RostersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RostersPage> createState() => _RostersPageState();
}

class _RostersPageState extends ConsumerState<RostersPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams & Rosters'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                // Update search query
                ref.read(teamSearchQueryProvider.notifier).update(value);
              },
              decoration: InputDecoration(
                hintText: 'Search teams...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Team list
          Expanded(
            child: _buildTeamList(),
          ),
        ],
      ),

      // Add team button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open add team form
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Team - Coming Soon!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build team list
  Widget _buildTeamList() {
    final filteredTeamsAsync = ref.watch(filteredTeamsProvider);

    return filteredTeamsAsync.when(
      // Loading state
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading teams...'),
          ],
        ),
      ),

      // Error state
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh
                ref.invalidate(teamsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),

      // Success state
      data: (teams) {
        // Empty state
        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No teams found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.watch(teamSearchQueryProvider).isNotEmpty
                      ? 'Try a different search'
                      : 'Create your first team!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Show teams
        return RefreshIndicator(
          // Swipe down to refresh
          onRefresh: () async {
            ref.invalidate(teamsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return TeamCard(
                name: team.name,
                description: team.description,
                memberCount: team.memberCount,
                onTap: () {
                  // Show team details
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing ${team.name} details'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/team.dart';
import '../data/repositories/team_repository.dart';
import 'event_provider.dart';

// Provider for team repository
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TeamRepository(apiService);
});

// Provider for all teams
final teamsProvider = FutureProvider<List<Team>>((ref) async {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getTeams();
});

// State provider for search query
final teamSearchQueryProvider = NotifierProvider<TeamSearchQueryNotifier, String>(() {
  return TeamSearchQueryNotifier();
});

class TeamSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

// Provider for filtered teams (with search)
final filteredTeamsProvider = Provider<AsyncValue<List<Team>>>((ref) {
  final teamsAsync = ref.watch(teamsProvider);
  final searchQuery = ref.watch(teamSearchQueryProvider);

  return teamsAsync.when(
    data: (teams) {
      // If no search, return all teams
      if (searchQuery.isEmpty) {
        return AsyncValue.data(teams);
      }

      // Filter by search query
      final query = searchQuery.toLowerCase();
      final filtered = teams.where((team) {
        return team.name.toLowerCase().contains(query) ||
               team.description.toLowerCase().contains(query);
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

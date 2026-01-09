import '../models/team.dart';
import '../services/api_service.dart';
import '../services/mock_team_data.dart';

// Repository to manage team data
class TeamRepository {
  final ApiService _apiService;
  
  // Cache stuff so we dont spam the API
  List<Team>? _cachedTeams;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 5);

  TeamRepository(this._apiService);

  // Get all teams
  Future<List<Team>> getTeams() async {
    // Check if we have fresh cache
    if (_cachedTeams != null && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < cacheDuration) {
        print('📦 Using cached teams');
        return _cachedTeams!;
      }
    }

    // Try getting from API
    try {
      print('🌐 Fetching teams from API...');
      final response = await _apiService.get('/teams');
      
      final List<dynamic> teamsJson = response.data;
      final teams = teamsJson.map((json) => Team.fromJson(json)).toList();
      
      // Save to cache
      _cachedTeams = teams;
      _lastFetchTime = DateTime.now();
      
      print('✅ Got ${teams.length} teams from API');
      return teams;
      
    } catch (e) {
      print('❌ API error, using mock data: $e');
      
      // If we have old cache, use that
      if (_cachedTeams != null) {
        print('📦 Returning old cached teams');
        return _cachedTeams!;
      }
      
      // Otherwise use mock data
      print('🎭 Using mock teams');
      final mockTeams = MockTeamData.getMockTeams();
      _cachedTeams = mockTeams;
      _lastFetchTime = DateTime.now();
      return mockTeams;
    }
  }

  // Get one team by id
  Future<Team?> getTeamById(int id) async {
    try {
      print('🌐 Fetching team #$id...');
      final response = await _apiService.get('/teams/$id');
      return Team.fromJson(response.data);
    } catch (e) {
      print('❌ Error getting team: $e');
      
      // Try finding in cache
      if (_cachedTeams != null) {
        try {
          return _cachedTeams!.firstWhere((team) => team.id == id);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }

  // Create new team
  Future<Team> createTeam(Team team) async {
    try {
      print('🌐 Creating team: ${team.name}...');
      
      final response = await _apiService.post('/teams', data: team.toJson());
      final newTeam = Team.fromJson(response.data);
      
      // Clear cache
      _clearCache();
      
      print('✅ Team created: ${newTeam.name}');
      return newTeam;
      
    } catch (e) {
      print('❌ Error creating team: $e');
      throw Exception('Failed to create team: $e');
    }
  }

  // Update existing team
  Future<Team> updateTeam(int id, Team team) async {
    try {
      print('🌐 Updating team #$id...');
      
      final response = await _apiService.put('/teams/$id', data: team.toJson());
      final updatedTeam = Team.fromJson(response.data);
      
      // Clear cache
      _clearCache();
      
      print('✅ Team updated');
      return updatedTeam;
      
    } catch (e) {
      print('❌ Error updating team: $e');
      throw Exception('Failed to update team: $e');
    }
  }

  // Delete team
  Future<void> deleteTeam(int id) async {
    try {
      print('🌐 Deleting team #$id...');
      
      await _apiService.delete('/teams/$id');
      
      // Clear cache
      _clearCache();
      
      print('✅ Team deleted');
      
    } catch (e) {
      print('❌ Error deleting team: $e');
      throw Exception('Failed to delete team: $e');
    }
  }

  // Search teams by name or description
  Future<List<Team>> searchTeams(String query) async {
    final allTeams = await getTeams();
    final lowerQuery = query.toLowerCase();
    
    return allTeams.where((team) {
      return team.name.toLowerCase().contains(lowerQuery) ||
             team.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear cache
  void _clearCache() {
    _cachedTeams = null;
    _lastFetchTime = null;
    print('🗑️ Cache cleared');
  }

  // Force refresh
  Future<List<Team>> refreshTeams() async {
    _clearCache();
    return await getTeams();
  }
}

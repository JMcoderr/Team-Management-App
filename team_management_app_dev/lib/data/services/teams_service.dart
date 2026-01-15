import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import 'auth_service.dart';

class TeamsService {
  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';

  // Fetch teams
  Future<List<Team>> fetchTeams(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body['error'] != null) {
        throw Exception((body['error'] as List).join(', '));
      }

      final List<dynamic>? teamsJson = body['data'];

      if (teamsJson != null) {
        // Convert each JSON team to a Team object
        return teamsJson.map((json) => Team.fromJson(json)).toList();
      } else {
        throw Exception('Teams not found in response');
      }
    }

    throw Exception('Failed to fetch teams with status ${response.statusCode}');
  }

  // Create team
  Future<void> createTeam({required String name, required String description}) async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create team (${response.statusCode})');
    }
  }

  // Edit team
  Future<void> editTeam({required int teamId, required String name, required String description}) async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.put(
      Uri.parse('$baseUrl/teams/$teamId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit team (${response.statusCode})');
    }
  }
}



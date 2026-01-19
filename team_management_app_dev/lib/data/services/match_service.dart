import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MatchService {
  static const String baseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  // Create match
  Future<void> createMatch({
    required String title,
    required String description,
    required String datetimeStart,
    required String datetimeEnd,
    required double latitude,
    required double longitude,
    required int teamId,
    required int opponentTeamId,
    required String instructions,
  }) async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.post(
      Uri.parse('$baseUrl/matches'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'datetimeStart': datetimeStart,
        'datetimeEnd': datetimeEnd,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'teamId': teamId,
        'metadata': {
          'instructions': instructions,
        },
        'invites': [
          {
            'teamId': opponentTeamId,
          }
        ]
      }),
    );

  // check if team was created
  if (response.statusCode != 201) {
    throw Exception('Failed to create match (${response.statusCode})');
  }

  }

  // Create list of all matches user is part of

  // Edit match

  // Delete match

  // Get match details

  // Get all match invites
  Future<List<dynamic>> fetchMatchInvites() async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.get(
      Uri.parse('$baseUrl/matches/invites'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      final pendingInvites = body['data']?.where((invite) {
        final status = (invite['status']).toString().trim().toLowerCase();
        return status == 'pending';
      }).toList(); 

      return pendingInvites;
    } else {
      throw Exception('Failed to fetch match invites (${response.statusCode})');
    }
  }


  // Get all matches 
  Future<List<dynamic>> fetchAllMatches() async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.get(
      Uri.parse('$baseUrl/matches'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to fetch matches (${response.statusCode})');
    }
  }


  // Get all matches and invite details then
  Future<List<Map<String, dynamic>>> getAllInviteDetails(int userId) async {
    final invites = await fetchMatchInvites();
    final matches = await fetchAllMatches();

    List<Map<String, dynamic>> combined = [];

    for (var invite in invites) {
      final matchId = invite['matchId'];

      final match = matches.firstWhere(
        (m) => m['id'] == matchId,
        orElse: () => null,
      );

      if (match != null) {
        combined.add({
          'inviteId': invite['id'],
          'matchId': matchId,
          'status': invite['status'],
          'match': match,
        });
      }
    }

    return combined;
  }

  // Accept match invite
  Future<void> acceptMatchInvite({ required int inviteId,}) async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.post(
      Uri.parse('$baseUrl/matches/invites/$inviteId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': 'accepted',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to respond to match invite (${response.statusCode})');
    }
  }

  // Decline match invite
  Future<void> declineMatchInvite({required int inviteId,}) async {
    final auth = AuthService();
    final token = auth.token;
    final response = await http.post(
      Uri.parse('$baseUrl/matches/invites/$inviteId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': 'declined',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to respond to match invite (${response.statusCode})');
    }
  }
}
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

    // Accept or Decline match invite

}
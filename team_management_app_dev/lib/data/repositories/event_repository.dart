import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../services/auth_service.dart';

class EventRepository {
  static const String baseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';
  final auth = AuthService();

  EventRepository();

  // Get all events
  Future<List<Event>> getEvents() async {
    final token = auth.token;

    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic>? eventsJson = body['data'];

      if (eventsJson != null) {
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      }
    }

    throw Exception('Failed to load events');
  }

  // Get event by ID
  Future<Event> getEventById(int id) async {
    final token = auth.token;

    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Event.fromJson(body['data']);
    }

    throw Exception('Failed to load event');
  }

  // Create new event
  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final token = auth.token;

    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body.containsKey('data')) {
        return Event.fromJson(body['data']);
      } else {
        return Event.fromJson(body);
      }
    }

    throw Exception(
      'Failed to create event: ${response.statusCode} - ${response.body}',
    );
  }

  // Update event
  Future<Event> updateEvent(int id, Map<String, dynamic> eventData) async {
    final token = auth.token;

    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Event.fromJson(body['data']);
    }

    throw Exception('Failed to update event');
  }

  // Delete event
  Future<void> deleteEvent(int id) async {
    final token = auth.token;

    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
}

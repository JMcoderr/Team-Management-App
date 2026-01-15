import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';

  // Login
  Future<String> login(String name, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    // Check if API returns success response
    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> body = jsonDecode(response.body);

      // Optional: check if the API returned an error
      if (body['error'] != null) {
        throw Exception(body['error']);
      }

      // Extract token from nested 'data'
      final String? token = body['data']['token'];
      
      if (token != null) {
        return token;
      } else {
        throw Exception('Token not found in response');
      }  
    }
    throw Exception('Login failed with status ${response.statusCode}');
  }

  // Register
  Future<void> register(String name, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Registration failed');
    }
  }
}
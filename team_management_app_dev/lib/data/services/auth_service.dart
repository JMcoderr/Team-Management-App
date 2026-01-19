import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';
  
  // Create a singleton instance to remember auth state
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  int? _userId;

  // Get token
  String get token {
    if (_token == null) {
      throw Exception('Auth token not set');
    }
    return _token!;
  }

  // get userId
  int get userId {
    if (_userId == null) {
      throw Exception('User ID not set');
    }
    return _userId!;
  }

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

    // Check for succes
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      // Get token and userId
      final String token = body['data']['token'];
      final int userId = body['data']['id'];

      // Store token and userId
      _token = token;
      _userId = userId;

      print ('Logged in as user $userId');
      print ('Token: $token');

      return token;
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

  // Logout
  void logout() {
    _token = null;
    _userId = null;
  }
}

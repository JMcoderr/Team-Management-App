import 'dart:convert';
import 'package:http/http.dart' as http;

// AuthService handles user authentication
// Uses singleton pattern to maintain auth state across the app
class AuthService {
  static const String baseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  // Singleton pattern - only one instance exists
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Store token and userId in memory
  String? _token;
  int? _userId;

  bool get isLoggedIn => _token != null;

  String get token {
    if (_token == null) {
      throw Exception('Auth token not set');
    }
    return _token!;
  }

  int get userId {
    if (_userId == null) {
      throw Exception('User ID not set');
    }
    return _userId!;
  }

  // 🔐 Login
  Future<void> login(String name, String password) async {
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

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['error'] != null) {
      throw Exception(body['error']);
    }

    final data = body['data'];
    final String? token = data['token'];
    final int? userId = data['id'];

    if (token == null || userId == null) {
      throw Exception('Invalid login response');
    }

    // Store globally
    _token = token;
    _userId = userId;
  }

  void logout() {
    _token = null;
    _userId = null;
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
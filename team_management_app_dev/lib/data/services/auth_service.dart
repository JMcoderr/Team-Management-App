import 'dart:convert';
import 'package:http/http.dart' as http;

// AuthService handles user authentication
// uses singleton pattern because we need the same token and user data accessible everywhere
class AuthService {
  static const String baseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  // singleton pattern implementation, _instance holds the one and only AuthService object
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance; // existing instead of new one

  AuthService._internal(); // nobody can create new instance

  // store JWT token and user ID in memory 
  String? _token;
  int? _userId; 

  // getter to check if user is logged in
  bool get isLoggedIn => _token != null;

  // getter to get token
  String get token {
    if (_token == null) {
      throw Exception('Auth token not set');
    }
    return _token!;
  }

  // getter to get user ID, used to filter teams/events by current user
  int get userId {
    if (_userId == null) {
      throw Exception('User ID not set');
    }
    return _userId!;
  }

  // login function sends username and password to API, if successful it saves token and userId for future requests
  Future<void> login(String name, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', 
      },
      body: jsonEncode({'name': name, 'password': password}),
    );

    // check if request failed (not 200 OK)
    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    // parse JSON response
    final Map<String, dynamic> body = jsonDecode(response.body);

    // check if API returned error message
    if (body['error'] != null) {
      throw Exception(body['error']);
    }

    // extract token and userId from response
    final data = body['data'];
    final String? token = data['token'];
    final int? userId = data['id'];

    // verify we got both token and userId
    if (token == null || userId == null) {
      throw Exception('Invalid login response');
    }

    // save token and userId so we can use them for future API calls
    _token = token;
    _userId = userId;
  }

  // logout clears token and userId from memory
  void logout() {
    _token = null;
    _userId = null;
  }

  // register function creates new user account
  Future<void> register(String name, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Registration failed');
    }
  }
}

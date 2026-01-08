import 'package:dio/dio.dart';

/// ApiService - The "Waiter" that talks to the school API
/// 
/// Think of this as the person who takes your order (request) 
/// and brings back food (data) from the kitchen (server)
class ApiService {
  // DIO = The phone line to the restaurant
  final Dio _dio;

  // BASE URL = The restaurant's address
  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';

  // CONSTRUCTOR: Set up the phone line when app starts
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),  // Wait max 10 seconds to connect
    receiveTimeout: const Duration(seconds: 10),  // Wait max 10 seconds for response
    headers: {
      'Content-Type': 'application/json',  // We speak JSON language
      'Accept': 'application/json',
    },
  )) {
    // Add logging so we can see what's happening (helpful for debugging!)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,   // Show what we send
      responseBody: true,  // Show what we get back
      error: true,         // Show errors
    ));
  }

  // AUTH TOKEN: Like showing your VIP card to get in
  // When user logs in, we save their token here
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // ==================== HTTP METHODS ====================
  // These are like different ways to order:
  // GET = "What's on the menu?" (read data)
  // POST = "I want to order this" (create new data)
  // PUT = "Change my order" (update existing data)
  // DELETE = "Cancel my order" (remove data)

  /// GET - Fetch data from API
  /// Example: "Give me all events"
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST - Send new data to API
  /// Example: "Create a new event with this info"
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT - Update existing data
  /// Example: "Update event #5 with new info"
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE - Remove data
  /// Example: "Delete event #5"
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================
  // When something goes wrong, explain it in simple terms

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - Check your internet!';
      
      case DioExceptionType.sendTimeout:
        return 'Send timeout - Taking too long to send data';
      
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - Server is taking too long to respond';
      
      case DioExceptionType.badResponse:
        // Server responded but with error (404, 500, etc.)
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request - Check your data!';
          case 401:
            return 'Unauthorized - Please log in again';
          case 403:
            return 'Forbidden - You don\'t have permission';
          case 404:
            return 'Not found - Data doesn\'t exist';
          case 500:
            return 'Server error - Try again later';
          default:
            return 'Error: ${error.response?.statusMessage ?? 'Unknown error'}';
        }
      
      case DioExceptionType.cancel:
        return 'Request cancelled';
      
      default:
        return 'Network error - Check your connection!';
    }
  }
}

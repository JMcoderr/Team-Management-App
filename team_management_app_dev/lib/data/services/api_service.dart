import 'package:dio/dio.dart';

// API Service - handles all HTTP requests to the backend
class ApiService {
  final Dio _dio;
  
  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';

  // Initialize dio with base settings
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    // Add interceptor to log requests/responses for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Store auth token when user logs in
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // GET request - fetch data
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request - create new data
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT - Update existing data
  // PUT request - update existing dataic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE - Remove data
  /// Example: "Delete event #5"
  Fu DELETE request - remove data
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================
  // When something goes wrong, explain it in simple terms
Handle errors and return user-friendly messages    switch (error.type) {
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

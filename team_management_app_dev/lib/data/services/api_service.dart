import 'package:dio/dio.dart';

// handling http requests to backend
class ApiService {
  final Dio _dio;

  static const String baseUrl = 'https://team-managment-api.dendrowen.com/api/v2';

  // dio setup - no longer singleton to match Jay's approach
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

  // auth token storage - kept for consistency with Jay's approach
  // ignore: unused_field
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // Get request fetch data
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Post request create new data
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // put request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete request - remove data
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // handling errors
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

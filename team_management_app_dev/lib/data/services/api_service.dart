import 'package:dio/dio.dart';

// ApiService handles all HTTP requests to backend
// uses Dio for better error handling and request logging
class ApiService {
  final Dio _dio;

  static const String baseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  // initializes Dio with default settings for all requests
  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10), // fail if no response
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json', // sending JSON
            'Accept': 'application/json', // expecting JSON back
          },
        ),
      ) {
    // logs all requests and responses for debugging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  String? _authToken;

  // adds JWT token to all future requests, called after login to authenticate API calls
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // removes token from requests
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // GET request fetches data from server, is used for reading teams, events, etc
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request sends new data to server used for creating teams, events, etc
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request updates existing data on server used for editing teams, events, etc

  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request - removes data from server used for deleting teams, events, etc
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // converts Dio errors to readable messages for user
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

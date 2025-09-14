import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://1259132592-gkfgf7rfne.ap-shanghai.tencentscf.com';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _getHeadersWithAuth(token),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic body, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _getHeadersWithAuth(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic body, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _getHeadersWithAuth(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _getHeadersWithAuth(token),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, String> _getHeadersWithAuth(String? token) {
    if (token != null) {
      return {
        ..._headers,
        'Authorization': 'Bearer $token',
      };
    }
    return _headers;
  }

  dynamic _handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: responseData['message'] ?? '请求失败',
        errors: responseData['errors'],
      );
    }
  }

  dynamic _handleError(dynamic e) {
    if (e is ApiException) {
      throw e;
    } else if (e is TimeoutException) {
      throw ApiException(message: '请求超时，请检查网络连接');
    } else {
      throw ApiException(message: '网络错误: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic errors;

  ApiException({
    this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status $statusCode)' : ''}';
  }
}

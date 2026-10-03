import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void setToken(String token) {
    _authToken = token;
  }

  void clearToken() {
    _authToken = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    return _request(() => _client.get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders()));
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() => _client.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getHeaders(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() => _client.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getHeaders(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String endpoint) async {
    return _request(() => _client.delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders()));
  }

  Future<dynamic> _request(Future<http.Response> Function() req) async {
    try {
      final response = await req();
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('No Internet connection or server unreachable.');
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorizedException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 500:
      default:
        throw FetchDataException('Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

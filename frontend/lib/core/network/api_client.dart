import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  static String? _sessaoCompartilhada;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  String? get _idSessao => _sessaoCompartilhada;
  set _idSessao(String? valor) => _sessaoCompartilhada = valor;

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  void definirIdSessao(String idSessao) {
    _sessaoCompartilhada = idSessao;
  }

  void limparIdSessao() {
    _sessaoCompartilhada = null;
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_idSessao != null && _idSessao!.isNotEmpty) {
      headers['X-Session-Id'] = _idSessao!;
      if (!kIsWeb) {
        headers['Cookie'] = 'idSessao=$_idSessao';
      }
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
    // Interceptar cookie de sessão via cabeçalho Set-Cookie, se disponível
    final setCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (setCookie != null && setCookie.contains('idSessao=')) {
      final match = RegExp(r'idSessao=([^;]+)').firstMatch(setCookie);
      if (match != null) {
        definirIdSessao(match.group(1)!);
      }
    }

    // Interceptar header customizado se o servidor tiver retornado
    final sessionHeader = response.headers['x-session-id'] ?? response.headers['X-Session-Id'];
    if (sessionHeader != null && sessionHeader.isNotEmpty) {
      definirIdSessao(sessionHeader);
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final bodySessionId = decoded['idSessao'] ?? decoded['sessionId'];
          if (bodySessionId != null && bodySessionId.toString().isNotEmpty) {
            definirIdSessao(bodySessionId.toString());
          }
        }
        return decoded;
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

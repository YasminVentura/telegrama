import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';
import 'session_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  static String? _sessaoCompartilhada = SessionStorage.getSessionId();
  static String? _refreshTokenCompartilhado = SessionStorage.getRefreshToken();
  static bool _isRefreshing = false;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  String? get idSessaoAtual => _sessaoCompartilhada ?? SessionStorage.getSessionId();
  String? get refreshTokenAtual => _refreshTokenCompartilhado ?? SessionStorage.getRefreshToken();

  static bool get possuiCredenciaisSalvas {
    final s = _sessaoCompartilhada ?? SessionStorage.getSessionId();
    final r = _refreshTokenCompartilhado ?? SessionStorage.getRefreshToken();
    return (s != null && s.isNotEmpty) || (r != null && r.isNotEmpty);
  }

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client() {
    _sessaoCompartilhada ??= SessionStorage.getSessionId();
    _refreshTokenCompartilhado ??= SessionStorage.getRefreshToken();
  }

  void definirIdSessao(String idSessao) {
    if (idSessao.isEmpty) return;
    _sessaoCompartilhada = idSessao;
    SessionStorage.saveSessionId(idSessao);
  }

  void definirRefreshToken(String refreshToken) {
    if (refreshToken.isEmpty) return;
    _refreshTokenCompartilhado = refreshToken;
    SessionStorage.saveRefreshToken(refreshToken);
  }

  void limparIdSessao() {
    _sessaoCompartilhada = null;
    _refreshTokenCompartilhado = null;
    SessionStorage.clearAll();
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final sessao = idSessaoAtual;
    final refresh = refreshTokenAtual;
    if (sessao != null && sessao.isNotEmpty) {
      headers['X-Session-Id'] = sessao;
      if (!kIsWeb) {
        headers['Cookie'] = 'idSessao=$sessao';
      }
    }
    if (refresh != null && refresh.isNotEmpty) {
      headers['X-Refresh-Token'] = refresh;
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    return _request(
      endpoint,
      () => _client.get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders()),
    );
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(
      endpoint,
      () => _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(
      endpoint,
      () => _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> delete(String endpoint) async {
    return _request(
      endpoint,
      () => _client.delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders()),
    );
  }

  Future<dynamic> _request(
    String endpoint,
    Future<http.Response> Function() req,
  ) async {
    try {
      http.Response response = await req();

      final bool isAuthEndpoint = endpoint.startsWith('/auth/login') ||
          endpoint.startsWith('/auth/registro') ||
          endpoint.startsWith('/auth/refresh');

      if ((response.statusCode == 401 || response.statusCode == 403) &&
          !isAuthEndpoint &&
          !_isRefreshing &&
          refreshTokenAtual != null &&
          refreshTokenAtual!.isNotEmpty) {
        final renovou = await tentarRenovarSessao();
        if (renovou) {
          response = await req();
        }
      }

      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('No Internet connection or server unreachable.');
    }
  }

  Future<bool> tentarRenovarSessao() async {
    final token = refreshTokenAtual;
    if (token == null || token.isEmpty || _isRefreshing) return false;

    _isRefreshing = true;
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Refresh-Token': token,
        },
        body: jsonEncode({'refreshToken': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _processResponse(response);
        return true;
      } else {
        limparIdSessao();
        return false;
      }
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  dynamic _processResponse(http.Response response) {
    final setCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (setCookie != null) {
      if (setCookie.contains('idSessao=')) {
        final match = RegExp(r'idSessao=([^;]+)').firstMatch(setCookie);
        if (match != null && match.group(1)!.isNotEmpty) {
          definirIdSessao(match.group(1)!);
        }
      }
      if (setCookie.contains('refreshToken=')) {
        final match = RegExp(r'refreshToken=([^;]+)').firstMatch(setCookie);
        if (match != null && match.group(1)!.isNotEmpty) {
          definirRefreshToken(match.group(1)!);
        }
      }
    }

    final sessionHeader = response.headers['x-session-id'] ?? response.headers['X-Session-Id'];
    if (sessionHeader != null && sessionHeader.isNotEmpty) {
      definirIdSessao(sessionHeader);
    }

    final refreshHeader = response.headers['x-refresh-token'] ?? response.headers['X-Refresh-Token'];
    if (refreshHeader != null && refreshHeader.isNotEmpty) {
      definirRefreshToken(refreshHeader);
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
          final bodyRefreshToken = decoded['refreshToken'];
          if (bodyRefreshToken != null && bodyRefreshToken.toString().isNotEmpty) {
            definirRefreshToken(bodyRefreshToken.toString());
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
        throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  static String? _sessaoCompartilhada;

  String? get _idSessao => _sessaoCompartilhada;
  set _idSessao(String? valor) => _sessaoCompartilhada = valor;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void definirIdSessao(String idSessao) {
    _sessaoCompartilhada = idSessao;
  }

  void limparIdSessao() {
    _sessaoCompartilhada = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_idSessao != null) {
      headers['Cookie'] = 'idSessao=$_idSessao';
      headers['X-Session-Id'] = _idSessao!;
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
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Interceptar idSessao retornado no corpo JSON (essencial para navegadores/Flutter Web)
          if (decoded['idSessao'] != null) {
            definirIdSessao(decoded['idSessao'].toString());
          } else if (decoded['token'] != null) {
            definirIdSessao(decoded['token'].toString());
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

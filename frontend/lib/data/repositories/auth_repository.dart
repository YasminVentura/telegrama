import 'package:frontend/core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(baseUrl: 'http://127.0.0.1:8080');

  Future<void> login(String identificador, String senha) async {
    await _apiClient.post('/auth/login', body: {
      'identificador': identificador,
      'senha': senha,
    });
    // O idSessao será interceptado automaticamente pelo ApiClient na resposta HTTP
  }

  Future<void> registro(String nome, String nodeId, String email, String senha, bool termosAceitos) async {
    await _apiClient.post('/auth/registro', body: {
      'nome': nome,
      'nodeId': nodeId,
      'email': email,
      'senha': senha,
      'termosAceitos': termosAceitos,
    });
  }
}

import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ??
            ApiClient(
              baseUrl: kIsWeb
                  ? 'http://localhost:8080'
                  : (defaultTargetPlatform == TargetPlatform.android
                      ? 'http://10.0.2.2:8080'
                      : 'http://localhost:8080'),
            );

  Future<dynamic> login(String identificador, String senha) async {
    final resposta = await _apiClient.post('/auth/login', body: {
      'identificador': identificador,
      'senha': senha,
    });
    // O idSessao será interceptado automaticamente pelo ApiClient via cookie ou header
    return resposta;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } finally {
      _apiClient.limparIdSessao();
    }
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

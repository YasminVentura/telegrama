import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/data/repositories/user_repository.dart';

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
    if (resposta is Map) {
      final sessionId = resposta['idSessao'] ?? resposta['sessionId'];
      if (sessionId != null && sessionId.toString().isNotEmpty) {
        _apiClient.definirIdSessao(sessionId.toString());
      }
      final refreshToken = resposta['refreshToken'];
      if (refreshToken != null && refreshToken.toString().isNotEmpty) {
        _apiClient.definirRefreshToken(refreshToken.toString());
      }
      UserRepositoryImpl.syncUserSession(
        id: resposta['id']?.toString(),
        nome: resposta['nome']?.toString(),
        nodeId: resposta['nodeId']?.toString(),
        email: resposta['email']?.toString(),
        role: (resposta['perfil'] ?? resposta['role'])?.toString(),
      );
    }
    return resposta;
  }

  Future<bool> restaurarSessao() async {
    if (!ApiClient.possuiCredenciaisSalvas) {
      UserRepositoryImpl.clearUserSession();
      return false;
    }

    UserRepositoryImpl.restoreCachedUserSession();

    try {
      final userRepository = UserRepositoryImpl(apiClient: _apiClient);
      await userRepository.getMyProfile();
      return true;
    } catch (_) {
      // Se falhou mesmo após a tentativa automática de refresh no ApiClient, tenta explicitamente o refresh:
      final renovou = await _apiClient.tentarRenovarSessao();
      if (renovou) {
        try {
          final userRepository = UserRepositoryImpl(apiClient: _apiClient);
          await userRepository.getMyProfile();
          return true;
        } catch (_) {}
      }
      UserRepositoryImpl.clearUserSession();
      _apiClient.limparIdSessao();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {
    } finally {
      UserRepositoryImpl.clearUserSession();
      _apiClient.limparIdSessao();
    }
  }

  Future<void> registro(
    String nome,
    String nodeId,
    String email,
    String senha,
    bool termosAceitos, {
    String? avatarUrl,
  }) async {
    final resposta = await _apiClient.post('/auth/registro', body: {
      'nome': nome,
      'nodeId': nodeId,
      'email': email,
      'senha': senha,
      'termosAceitos': termosAceitos,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
    });
    if (resposta is Map) {
      final sessionId = resposta['idSessao'] ?? resposta['sessionId'];
      if (sessionId != null && sessionId.toString().isNotEmpty) {
        _apiClient.definirIdSessao(sessionId.toString());
      }
      final refreshToken = resposta['refreshToken'];
      if (refreshToken != null && refreshToken.toString().isNotEmpty) {
        _apiClient.definirRefreshToken(refreshToken.toString());
      }
      UserRepositoryImpl.syncUserSession(
        id: resposta['id']?.toString(),
        nome: resposta['nome']?.toString(),
        nodeId: resposta['nodeId']?.toString(),
        email: resposta['email']?.toString(),
        role: (resposta['perfil'] ?? resposta['role'])?.toString(),
        avatarUrl: avatarUrl,
        fromExplicitUserSelection: avatarUrl != null && avatarUrl.isNotEmpty,
      );
    } else {
      await login(email, senha);
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        UserRepositoryImpl.setExplicitAvatarChoice(avatarUrl);
      }
    }
  }
}

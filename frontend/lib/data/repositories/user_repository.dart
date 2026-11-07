import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/data/models/user_preferences.dart';

/// DTO que mapeia a resposta do endpoint GET /usuarios/{nodeId} e GET /usuarios/me
class PerfilRespostaDto {
  final String id;
  final String nome;
  final String email;
  final String nodeId;
  final String? bio;
  final String? localizacao;
  final String? avatarUrl;
  final int seguidoresCount;
  final int seguindoCount;
  final bool isMe;
  final UserPreferences? preferencias;

  PerfilRespostaDto({
    required this.id,
    required this.nome,
    required this.email,
    required this.nodeId,
    this.bio,
    this.localizacao,
    this.avatarUrl,
    this.seguidoresCount = 0,
    this.seguindoCount = 0,
    this.isMe = false,
    this.preferencias,
  });

  factory PerfilRespostaDto.fromJson(Map<String, dynamic> json) {
    return PerfilRespostaDto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      nodeId: json['nodeId'] ?? '',
      bio: json['bio'],
      localizacao: json['localizacao'] ?? json['location'],
      avatarUrl: json['avatarUrl'],
      seguidoresCount: (json['quantidadeSeguidores'] ?? json['seguidoresCount'] ?? 0) as int,
      seguindoCount: (json['quantidadeSeguindo'] ?? json['seguindoCount'] ?? 0) as int,
      isMe: json['isMe'] == true,
      preferencias: json['preferencias'] != null 
          ? UserPreferences.fromJson(Map<String, dynamic>.from(json['preferencias']))
          : null,
    );
  }
}

/// DTO resumido para buscas e listagens em lote de usuários
class PerfilResumidoDto {
  final String id;
  final String nome;
  final String nodeId;
  final String? avatarUrl;

  PerfilResumidoDto({
    required this.id,
    required this.nome,
    required this.nodeId,
    this.avatarUrl,
  });

  factory PerfilResumidoDto.fromJson(Map<String, dynamic> json) {
    return PerfilResumidoDto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      nodeId: json['nodeId'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nodeId': nodeId,
      'avatarUrl': avatarUrl,
    };
  }
}

abstract class UserRepository {
  Future<PerfilRespostaDto> getMyProfile();
  Future<PerfilRespostaDto> getUserProfile(String nodeId);
  Future<PerfilRespostaDto> updateProfile(Map<String, dynamic> data);
  Future<UserPreferences> getPreferences();
  Future<UserPreferences> updatePreferences(Map<String, dynamic> prefs);
  Future<String> uploadAvatar(XFile image);
  Future<void> followUser(String nodeId);
  Future<void> unfollowUser(String nodeId);
  Future<List<PerfilResumidoDto>> searchUsers(String query);
}

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(
              baseUrl: kIsWeb
                  ? 'http://localhost:8080'
                  : (defaultTargetPlatform == TargetPlatform.android
                      ? 'http://10.0.2.2:8080'
                      : 'http://localhost:8080'),
            );

  @override
  Future<PerfilRespostaDto> getMyProfile() async {
    final response = await _apiClient.get('/usuarios/me');
    return PerfilRespostaDto.fromJson(response);
  }

  @override
  Future<PerfilRespostaDto> getUserProfile(String nodeId) async {
    final response = await _apiClient.get('/usuarios/$nodeId');
    return PerfilRespostaDto.fromJson(response);
  }

  @override
  Future<PerfilRespostaDto> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put('/usuarios/me', body: data);
    return PerfilRespostaDto.fromJson(response);
  }

  @override
  Future<UserPreferences> getPreferences() async {
    final response = await _apiClient.get('/usuarios/me/preferences');
    return UserPreferences.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<UserPreferences> updatePreferences(Map<String, dynamic> prefs) async {
    final response = await _apiClient.put('/usuarios/me/preferences', body: prefs);
    return UserPreferences.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> followUser(String nodeId) async {
    await _apiClient.post('/usuarios/$nodeId/seguir');
  }

  @override
  Future<void> unfollowUser(String nodeId) async {
    await _apiClient.delete('/usuarios/$nodeId/seguir');
  }

  @override
  Future<String> uploadAvatar(XFile image) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return 'https://exemplo.com/avatar_mock.jpg';
  }

  @override
  Future<List<PerfilResumidoDto>> searchUsers(String query) async {
    try {
      final response = await _apiClient.get('/usuarios/busca?q=${Uri.encodeComponent(query)}');
      List<dynamic> list = [];
      if (response is List) {
        list = response;
      } else if (response is Map && response['data'] is List) {
        list = response['data'];
      }
      return list.map((item) => PerfilResumidoDto.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      debugPrint('Erro ao buscar usuários: $e');
      return [];
    }
  }
}

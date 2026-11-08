import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/data/models/user_preferences.dart';
import 'package:frontend/shared/components/user_avatar.dart';

/// DTO que mapeia a resposta do endpoint GET /usuarios/{nodeId} e GET /usuarios/me
class PerfilRespostaDto {
  final String id;
  final String nome;
  final String email;
  final String nodeId;
  final String? bio;
  final String? localizacao;
  final String? avatarUrl;
  final String perfil;
  final int seguidoresCount;
  final int seguindoCount;
  final bool isMe;
  final bool isFollowing;
  final UserPreferences? preferencias;

  PerfilRespostaDto({
    required this.id,
    required this.nome,
    required this.email,
    required this.nodeId,
    this.bio,
    this.localizacao,
    this.avatarUrl,
    this.perfil = 'USER',
    this.seguidoresCount = 0,
    this.seguindoCount = 0,
    this.isMe = false,
    this.isFollowing = false,
    this.preferencias,
  });

  factory PerfilRespostaDto.fromJson(
    Map<String, dynamic> json, {
    String? fallbackAvatar,
  }) {
    final Map<String, dynamic>? prefsMap = json['preferencias'] != null
        ? Map<String, dynamic>.from(json['preferencias'])
        : null;

    final String? rawServerAvatar = UserPreferences.extractRawAvatar(json) ??
        UserPreferences.extractRawAvatar(prefsMap);

    final String effectiveFallback =
        fallbackAvatar ?? UserRepositoryImpl.selectedAvatarOrDefault;

    final String resolvedAvatar = UserAvatar.resolvePresetAsset(rawServerAvatar) ??
        ((rawServerAvatar != null && rawServerAvatar.isNotEmpty)
            ? rawServerAvatar
            : effectiveFallback);

    final UserPreferences prefs = prefsMap != null
        ? UserPreferences.fromJson(prefsMap, fallbackAvatar: resolvedAvatar)
            .copyWith(avatarUrl: resolvedAvatar)
        : UserPreferences(avatarUrl: resolvedAvatar);

    return PerfilRespostaDto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      nodeId: json['nodeId'] ?? '',
      bio: json['bio'],
      localizacao: json['localizacao'] ?? json['location'],
      avatarUrl: resolvedAvatar,
      perfil: (json['perfil'] ?? json['role'] ?? 'USER').toString().toUpperCase(),
      seguidoresCount: (json['quantidadeSeguidores'] ?? json['seguidoresCount'] ?? 0) as int,
      seguindoCount: (json['quantidadeSeguindo'] ?? json['seguindoCount'] ?? 0) as int,
      isMe: json['isMe'] == true || json['me'] == true,
      isFollowing: json['isFollowing'] == true || json['seguindo'] == true,
      preferencias: prefs,
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
    final String? rawAvatar = UserPreferences.extractRawAvatar(json);
    return PerfilResumidoDto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      nodeId: json['nodeId'] ?? '',
      avatarUrl: UserAvatar.resolvePresetAsset(rawAvatar) ?? rawAvatar,
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
  Future<void> deleteUser(String nodeId);
  Future<List<PerfilResumidoDto>> searchUsers(String query);
}

class UserRepositoryImpl implements UserRepository {
  /// Notificador global para manter a foto do perfil sincronizada entre Header, Perfil e Posts
  static final ValueNotifier<String> currentAvatarNotifier =
      ValueNotifier<String>(UserPreferences.defaultAvatar);
  static final ValueNotifier<String> currentUserNameNotifier =
      ValueNotifier<String>('User');
  static final ValueNotifier<String> currentUserRoleNotifier =
      ValueNotifier<String>('USER');

  static String? currentUserNodeId;
  static String? currentUserEmail;
  static String? currentUserId;

  static bool get isCurrentUserAdmin =>
      currentUserRoleNotifier.value.toUpperCase() == 'ADMIN';

  /// Guarda a foto escolhida pelo usuário para não perder mesmo se o container ainda não tiver reiniciado
  static String? _userExplicitlyChosenAvatar;
  static final Map<String, String> _avatarByNodeId = {};

  static String get selectedAvatarOrDefault =>
      _userExplicitlyChosenAvatar ?? currentAvatarNotifier.value;

  static void setExplicitAvatarChoice(String avatarUrl) {
    final resolved = UserAvatar.resolvePresetAsset(avatarUrl) ?? avatarUrl.trim();
    if (resolved.isEmpty) return;
    _userExplicitlyChosenAvatar = resolved;
    if (currentUserNodeId != null && currentUserNodeId!.isNotEmpty) {
      _avatarByNodeId[currentUserNodeId!.toLowerCase()] = resolved;
    }
    if (currentAvatarNotifier.value != resolved) {
      currentAvatarNotifier.value = resolved;
    }
  }

  static void syncUserSession({
    String? avatarUrl,
    String? nome,
    String? nodeId,
    String? email,
    String? id,
    String? role,
    bool fromExplicitUserSelection = false,
  }) {
    if (nodeId != null && nodeId.trim().isNotEmpty) {
      final incomingCleanNodeId = nodeId.trim().replaceAll('@', '');
      if (currentUserNodeId != null &&
          currentUserNodeId!.toLowerCase() != incomingCleanNodeId.toLowerCase()) {
        // Se trocou de usuário logado, limpa a escolha anterior em memória
        _userExplicitlyChosenAvatar = null;
      }
      currentUserNodeId = incomingCleanNodeId;
    }
    if (email != null && email.trim().isNotEmpty) {
      currentUserEmail = email.trim();
    }
    if (id != null && id.trim().isNotEmpty) {
      currentUserId = id.trim();
    }
    if (role != null && role.trim().isNotEmpty) {
      final normalizedRole = role.trim().toUpperCase();
      if (currentUserRoleNotifier.value != normalizedRole) {
        currentUserRoleNotifier.value = normalizedRole;
      }
    }
    if (nome != null && nome.trim().isNotEmpty) {
      if (currentUserNameNotifier.value != nome.trim()) {
        currentUserNameNotifier.value = nome.trim();
      }
    }

    if (fromExplicitUserSelection && avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      setExplicitAvatarChoice(avatarUrl);
      return;
    }

    // Se o usuário já escolheu uma foto na sessão, preserva a escolha dele
    if (_userExplicitlyChosenAvatar != null && _userExplicitlyChosenAvatar!.isNotEmpty) {
      if (currentAvatarNotifier.value != _userExplicitlyChosenAvatar!) {
        currentAvatarNotifier.value = _userExplicitlyChosenAvatar!;
      }
      return;
    }

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      final resolved = UserAvatar.resolvePresetAsset(avatarUrl) ?? avatarUrl.trim();
      if (currentAvatarNotifier.value != resolved) {
        currentAvatarNotifier.value = resolved;
      }
    }
  }

  static bool isCurrentUser(String? handleOrNodeId, {String? authorName}) {
    if (handleOrNodeId != null && handleOrNodeId.trim().isNotEmpty) {
      final cleanTarget = handleOrNodeId
          .trim()
          .replaceAll('telegrama.zone/', '')
          .replaceAll('@', '')
          .toLowerCase();

      if (currentUserNodeId != null &&
          cleanTarget == currentUserNodeId!.trim().replaceAll('@', '').toLowerCase()) {
        return true;
      }
      if (currentUserEmail != null &&
          cleanTarget == currentUserEmail!.trim().toLowerCase()) {
        return true;
      }
      if (currentUserId != null &&
          cleanTarget == currentUserId!.trim().toLowerCase()) {
        return true;
      }
    }

    if (authorName != null && authorName.trim().isNotEmpty) {
      final currentName = currentUserNameNotifier.value.trim().toLowerCase();
      if (currentName.isNotEmpty &&
          currentName != 'user' &&
          authorName.trim().toLowerCase() == currentName) {
        return true;
      }
    }

    return false;
  }

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
    final map = Map<String, dynamic>.from(response);

    // Se o servidor retornou um avatar explícito diferente do default, e o usuário ainda não trocou manualmente nesta sessão:
    final rawServerAvatar = UserPreferences.extractRawAvatar(map) ??
        (map['preferencias'] is Map
            ? UserPreferences.extractRawAvatar(Map<String, dynamic>.from(map['preferencias']))
            : null);

    final String effectiveAvatar = _userExplicitlyChosenAvatar ??
        UserAvatar.resolvePresetAsset(rawServerAvatar) ??
        rawServerAvatar ??
        currentAvatarNotifier.value;

    final dto = PerfilRespostaDto.fromJson(map, fallbackAvatar: effectiveAvatar);
    syncUserSession(
      avatarUrl: effectiveAvatar,
      nome: dto.nome,
      nodeId: dto.nodeId,
      email: dto.email,
      id: dto.id,
      role: dto.perfil,
    );
    return dto;
  }

  @override
  Future<PerfilRespostaDto> getUserProfile(String nodeId) async {
    final response = await _apiClient.get('/usuarios/$nodeId');
    final map = Map<String, dynamic>.from(response);
    final bool isMe = map['isMe'] == true ||
        map['me'] == true ||
        isCurrentUser(nodeId) ||
        isCurrentUser(map['nodeId']?.toString());

    final dto = PerfilRespostaDto.fromJson(
      map,
      fallbackAvatar: isMe ? selectedAvatarOrDefault : UserPreferences.defaultAvatar,
    );
    if (dto.isMe || isMe) {
      syncUserSession(
        avatarUrl: _userExplicitlyChosenAvatar ?? dto.preferencias?.avatarUrl ?? dto.avatarUrl,
        nome: dto.nome,
        nodeId: dto.nodeId,
        email: dto.email,
        id: dto.id,
        role: dto.perfil,
      );
    }
    return dto;
  }

  @override
  Future<PerfilRespostaDto> updateProfile(Map<String, dynamic> data) async {
    String? chosenAvatar = UserPreferences.extractRawAvatar(data);
    if (chosenAvatar == null && data['preferencias'] is Map) {
      chosenAvatar = UserPreferences.extractRawAvatar(
        Map<String, dynamic>.from(data['preferencias']),
      );
    }
    if (chosenAvatar != null) {
      setExplicitAvatarChoice(chosenAvatar);
    }
    if (data['nome'] != null) {
      syncUserSession(nome: data['nome'].toString());
    }

    final response = await _apiClient.put('/usuarios/me', body: data);
    final map = Map<String, dynamic>.from(response);
    final dto = PerfilRespostaDto.fromJson(
      map,
      fallbackAvatar: selectedAvatarOrDefault,
    );
    syncUserSession(
      avatarUrl: selectedAvatarOrDefault,
      nome: dto.nome,
      nodeId: dto.nodeId,
      email: dto.email,
      id: dto.id,
      role: dto.perfil,
    );
    return dto;
  }

  @override
  Future<UserPreferences> getPreferences() async {
    final response = await _apiClient.get('/usuarios/me/preferences');
    final map = Map<String, dynamic>.from(response);
    final prefs = UserPreferences.fromJson(
      map,
      fallbackAvatar: selectedAvatarOrDefault,
    );
    if (_userExplicitlyChosenAvatar == null) {
      final rawServerAvatar = UserPreferences.extractRawAvatar(map);
      if (rawServerAvatar != null) {
        syncUserSession(avatarUrl: rawServerAvatar);
      }
    }
    return prefs.copyWith(avatarUrl: selectedAvatarOrDefault);
  }

  @override
  Future<UserPreferences> updatePreferences(Map<String, dynamic> prefs) async {
    final chosenAvatar = UserPreferences.extractRawAvatar(prefs);
    if (chosenAvatar != null) {
      setExplicitAvatarChoice(chosenAvatar);
    }
    final response = await _apiClient.put('/usuarios/me/preferences', body: prefs);
    final map = Map<String, dynamic>.from(response);
    final updated = UserPreferences.fromJson(
      map,
      fallbackAvatar: selectedAvatarOrDefault,
    );
    return updated.copyWith(avatarUrl: selectedAvatarOrDefault);
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
  Future<void> deleteUser(String nodeId) async {
    await _apiClient.delete('/usuarios/$nodeId');
  }

  @override
  Future<String> uploadAvatar(XFile image) async {
    final resolved = UserAvatar.resolvePresetAsset(image.path) ?? UserPreferences.defaultAvatar;
    setExplicitAvatarChoice(resolved);
    await updatePreferences({'avatarUrl': resolved});
    return resolved;
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

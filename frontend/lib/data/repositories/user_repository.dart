import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/session_storage.dart';
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
  final String? bannerColor;
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
    this.bannerColor,
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
    String? fallbackBannerColor,
  }) {
    final Map<String, dynamic>? prefsMap = json['preferencias'] != null
        ? Map<String, dynamic>.from(json['preferencias'])
        : null;

    final String? rawServerAvatar = UserPreferences.extractRawAvatar(json) ??
        UserPreferences.extractRawAvatar(prefsMap);

    final String? rawServerBanner = UserPreferences.extractRawBannerColor(json) ??
        UserPreferences.extractRawBannerColor(prefsMap);

    final String effectiveFallback =
        fallbackAvatar ?? UserRepositoryImpl.selectedAvatarOrDefault;

    final String effectiveBannerFallback =
        fallbackBannerColor ?? UserRepositoryImpl.selectedBannerColorOrDefault;

    final String resolvedAvatar = UserAvatar.resolvePresetAsset(rawServerAvatar) ??
        ((rawServerAvatar != null && rawServerAvatar.isNotEmpty)
            ? rawServerAvatar
            : effectiveFallback);

    final String resolvedBannerColor =
        (rawServerBanner != null && rawServerBanner.isNotEmpty)
            ? rawServerBanner
            : effectiveBannerFallback;

    final UserPreferences prefs = prefsMap != null
        ? UserPreferences.fromJson(
            prefsMap,
            fallbackAvatar: resolvedAvatar,
            fallbackBannerColor: resolvedBannerColor,
          ).copyWith(
            avatarUrl: resolvedAvatar,
            bannerColor: resolvedBannerColor,
          )
        : UserPreferences(
            avatarUrl: resolvedAvatar,
            bannerColor: resolvedBannerColor,
          );

    return PerfilRespostaDto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      nodeId: json['nodeId'] ?? '',
      bio: json['bio'],
      localizacao: json['localizacao'] ?? json['location'],
      avatarUrl: resolvedAvatar,
      bannerColor: resolvedBannerColor,
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
  /// Notificador global para manter a foto e a cor do banner sincronizadas entre Header, Perfil e Posts
  static final ValueNotifier<String> currentAvatarNotifier =
      ValueNotifier<String>(UserPreferences.defaultAvatar);
  static final ValueNotifier<String> currentBannerColorNotifier =
      ValueNotifier<String>(UserPreferences.defaultBannerColor);
  static final ValueNotifier<String> currentUserNameNotifier =
      ValueNotifier<String>('User');
  static final ValueNotifier<String> currentUserRoleNotifier =
      ValueNotifier<String>('USER');
  static final ValueNotifier<bool> isLoggedInNotifier =
      ValueNotifier<bool>(false);

  static String? currentUserNodeId;
  static String? currentUserEmail;
  static String? currentUserId;

  static bool get isLoggedIn =>
      isLoggedInNotifier.value ||
      (currentUserNodeId != null && currentUserNodeId!.isNotEmpty);

  static bool get isCurrentUserAdmin =>
      isLoggedIn && currentUserRoleNotifier.value.toUpperCase() == 'ADMIN';

  /// Guarda a foto e a cor de fundo escolhidas pelo usuário na sessão atual
  static String? _userExplicitlyChosenAvatar;
  static String? _userExplicitlyChosenBannerColor;
  static final Map<String, String> _avatarByNodeId = {};

  static String get selectedAvatarOrDefault =>
      _userExplicitlyChosenAvatar ?? currentAvatarNotifier.value;

  static String get selectedBannerColorOrDefault =>
      _userExplicitlyChosenBannerColor ?? currentBannerColorNotifier.value;

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

  static void setExplicitBannerColorChoice(String bannerColor) {
    final resolved = bannerColor.trim();
    if (resolved.isEmpty) return;
    _userExplicitlyChosenBannerColor = resolved;
    if (currentBannerColorNotifier.value != resolved) {
      currentBannerColorNotifier.value = resolved;
    }
  }

  static void syncUserSession({
    String? avatarUrl,
    String? bannerColor,
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
        _userExplicitlyChosenBannerColor = null;
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

    if (fromExplicitUserSelection) {
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
        setExplicitAvatarChoice(avatarUrl);
      }
      if (bannerColor != null && bannerColor.trim().isNotEmpty) {
        setExplicitBannerColorChoice(bannerColor);
      }
      return;
    }

    if (_userExplicitlyChosenBannerColor != null &&
        _userExplicitlyChosenBannerColor!.isNotEmpty) {
      if (currentBannerColorNotifier.value != _userExplicitlyChosenBannerColor!) {
        currentBannerColorNotifier.value = _userExplicitlyChosenBannerColor!;
      }
    } else if (bannerColor != null && bannerColor.trim().isNotEmpty) {
      final resolvedBanner = bannerColor.trim();
      if (currentBannerColorNotifier.value != resolvedBanner) {
        currentBannerColorNotifier.value = resolvedBanner;
      }
    }

    // Se o usuário já escolheu uma foto na sessão, preserva a escolha dele
    if (_userExplicitlyChosenAvatar != null && _userExplicitlyChosenAvatar!.isNotEmpty) {
      if (currentAvatarNotifier.value != _userExplicitlyChosenAvatar!) {
        currentAvatarNotifier.value = _userExplicitlyChosenAvatar!;
      }
    } else if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      final resolved = UserAvatar.resolvePresetAsset(avatarUrl) ?? avatarUrl.trim();
      if (currentAvatarNotifier.value != resolved) {
        currentAvatarNotifier.value = resolved;
      }
    }

    if (currentUserNodeId != null && currentUserNodeId!.isNotEmpty) {
      if (!isLoggedInNotifier.value) {
        isLoggedInNotifier.value = true;
      }
      SessionStorage.saveUserData({
        'id': currentUserId,
        'nome': currentUserNameNotifier.value,
        'nodeId': currentUserNodeId,
        'email': currentUserEmail,
        'role': currentUserRoleNotifier.value,
        'avatarUrl': currentAvatarNotifier.value,
        'bannerColor': currentBannerColorNotifier.value,
      });
    }
  }

  static void restoreCachedUserSession() {
    final cached = SessionStorage.getUserData();
    if (cached == null) return;
    syncUserSession(
      id: cached['id']?.toString(),
      nome: cached['nome']?.toString(),
      nodeId: cached['nodeId']?.toString(),
      email: cached['email']?.toString(),
      role: cached['role']?.toString(),
      avatarUrl: cached['avatarUrl']?.toString(),
      bannerColor: cached['bannerColor']?.toString(),
    );
  }

  static void clearUserSession() {
    currentUserNodeId = null;
    currentUserEmail = null;
    currentUserId = null;
    _userExplicitlyChosenAvatar = null;
    _userExplicitlyChosenBannerColor = null;
    currentUserNameNotifier.value = 'User';
    currentUserRoleNotifier.value = 'USER';
    currentAvatarNotifier.value = UserPreferences.defaultAvatar;
    currentBannerColorNotifier.value = UserPreferences.defaultBannerColor;
    isLoggedInNotifier.value = false;
    SessionStorage.clearAll();
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

    final rawServerAvatar = UserPreferences.extractRawAvatar(map) ??
        (map['preferencias'] is Map
            ? UserPreferences.extractRawAvatar(Map<String, dynamic>.from(map['preferencias']))
            : null);

    final rawServerBanner = UserPreferences.extractRawBannerColor(map) ??
        (map['preferencias'] is Map
            ? UserPreferences.extractRawBannerColor(Map<String, dynamic>.from(map['preferencias']))
            : null);

    final String effectiveAvatar = _userExplicitlyChosenAvatar ??
        UserAvatar.resolvePresetAsset(rawServerAvatar) ??
        rawServerAvatar ??
        currentAvatarNotifier.value;

    final String effectiveBannerColor = _userExplicitlyChosenBannerColor ??
        rawServerBanner ??
        currentBannerColorNotifier.value;

    final dto = PerfilRespostaDto.fromJson(
      map,
      fallbackAvatar: effectiveAvatar,
      fallbackBannerColor: effectiveBannerColor,
    );
    syncUserSession(
      avatarUrl: effectiveAvatar,
      bannerColor: effectiveBannerColor,
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
      fallbackBannerColor:
          isMe ? selectedBannerColorOrDefault : UserPreferences.defaultBannerColor,
    );
    if (dto.isMe || isMe) {
      syncUserSession(
        avatarUrl: _userExplicitlyChosenAvatar ?? dto.preferencias?.avatarUrl ?? dto.avatarUrl,
        bannerColor: _userExplicitlyChosenBannerColor ??
            dto.preferencias?.bannerColor ??
            dto.bannerColor,
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

    String? chosenBanner = UserPreferences.extractRawBannerColor(data);
    if (chosenBanner == null && data['preferencias'] is Map) {
      chosenBanner = UserPreferences.extractRawBannerColor(
        Map<String, dynamic>.from(data['preferencias']),
      );
    }
    if (chosenBanner != null) {
      setExplicitBannerColorChoice(chosenBanner);
    }

    if (data['nome'] != null) {
      syncUserSession(nome: data['nome'].toString());
    }

    final response = await _apiClient.put('/usuarios/me', body: data);
    final map = Map<String, dynamic>.from(response);
    final dto = PerfilRespostaDto.fromJson(
      map,
      fallbackAvatar: selectedAvatarOrDefault,
      fallbackBannerColor: selectedBannerColorOrDefault,
    );
    syncUserSession(
      avatarUrl: selectedAvatarOrDefault,
      bannerColor: selectedBannerColorOrDefault,
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
      fallbackBannerColor: selectedBannerColorOrDefault,
    );
    if (_userExplicitlyChosenAvatar == null) {
      final rawServerAvatar = UserPreferences.extractRawAvatar(map);
      if (rawServerAvatar != null) {
        syncUserSession(avatarUrl: rawServerAvatar);
      }
    }
    if (_userExplicitlyChosenBannerColor == null) {
      final rawServerBanner = UserPreferences.extractRawBannerColor(map);
      if (rawServerBanner != null) {
        syncUserSession(bannerColor: rawServerBanner);
      }
    }
    return prefs.copyWith(
      avatarUrl: selectedAvatarOrDefault,
      bannerColor: selectedBannerColorOrDefault,
    );
  }

  @override
  Future<UserPreferences> updatePreferences(Map<String, dynamic> prefs) async {
    final chosenAvatar = UserPreferences.extractRawAvatar(prefs);
    if (chosenAvatar != null) {
      setExplicitAvatarChoice(chosenAvatar);
    }
    final chosenBanner = UserPreferences.extractRawBannerColor(prefs);
    if (chosenBanner != null) {
      setExplicitBannerColorChoice(chosenBanner);
    }
    final response = await _apiClient.put('/usuarios/me/preferences', body: prefs);
    final map = Map<String, dynamic>.from(response);
    final updated = UserPreferences.fromJson(
      map,
      fallbackAvatar: selectedAvatarOrDefault,
      fallbackBannerColor: selectedBannerColorOrDefault,
    );
    return updated.copyWith(
      avatarUrl: selectedAvatarOrDefault,
      bannerColor: selectedBannerColorOrDefault,
    );
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

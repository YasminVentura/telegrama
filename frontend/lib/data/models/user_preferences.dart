class UserPreferences {
  static const String defaultAvatar = 'lib/assets/images/avatars/avatar_1.webp';

  static const List<String> fixedAvatars = [
    'lib/assets/images/avatars/avatar_1.webp',
    'lib/assets/images/avatars/avatar_2.webp',
    'lib/assets/images/avatars/avatar_3.jpg',
    'lib/assets/images/avatars/avatar_4.jpg',
    'lib/assets/images/avatars/avatar_5.jpg',
    'lib/assets/images/avatars/avatar_6.jpg',
  ];

  final bool privateFrequencyMode;
  final bool directTransmissions;
  final bool broadcastNodeActivity;
  final bool pushTransmissions;
  final bool acousticEchos;
  final bool zoneBroadcastAlerts;
  final bool twoFactorAuth;
  final String theme;
  final String avatarUrl;

  const UserPreferences({
    this.privateFrequencyMode = false,
    this.directTransmissions = true,
    this.broadcastNodeActivity = true,
    this.pushTransmissions = true,
    this.acousticEchos = true,
    this.zoneBroadcastAlerts = false,
    this.twoFactorAuth = false,
    this.theme = 'RETRO_GREEN',
    this.avatarUrl = defaultAvatar,
  });

  static String? extractRawAvatar(Map<String, dynamic>? json) {
    if (json == null) return null;
    final raw = json['avatarUrl'] ??
        json['fotoPerfil'] ??
        json['profilePhoto'] ??
        json['avatar_url'] ??
        json['avatar'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString().trim();
    }
    return null;
  }

  factory UserPreferences.fromJson(
    Map<String, dynamic> json, {
    String? fallbackAvatar,
  }) {
    final rawAvatar = extractRawAvatar(json);
    return UserPreferences(
      privateFrequencyMode: json['privateFrequencyMode'] ?? false,
      directTransmissions: json['directTransmissions'] ?? true,
      broadcastNodeActivity: json['broadcastNodeActivity'] ?? true,
      pushTransmissions: json['pushTransmissions'] ?? true,
      acousticEchos: json['acousticEchos'] ?? true,
      zoneBroadcastAlerts: json['zoneBroadcastAlerts'] ?? false,
      twoFactorAuth: json['twoFactorAuth'] ?? false,
      theme: json['theme'] ?? 'RETRO_GREEN',
      avatarUrl: rawAvatar ?? fallbackAvatar ?? defaultAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privateFrequencyMode': privateFrequencyMode,
      'directTransmissions': directTransmissions,
      'broadcastNodeActivity': broadcastNodeActivity,
      'pushTransmissions': pushTransmissions,
      'acousticEchos': acousticEchos,
      'zoneBroadcastAlerts': zoneBroadcastAlerts,
      'twoFactorAuth': twoFactorAuth,
      'theme': theme,
      'avatarUrl': avatarUrl,
    };
  }

  UserPreferences copyWith({
    bool? privateFrequencyMode,
    bool? directTransmissions,
    bool? broadcastNodeActivity,
    bool? pushTransmissions,
    bool? acousticEchos,
    bool? zoneBroadcastAlerts,
    bool? twoFactorAuth,
    String? theme,
    String? avatarUrl,
  }) {
    return UserPreferences(
      privateFrequencyMode: privateFrequencyMode ?? this.privateFrequencyMode,
      directTransmissions: directTransmissions ?? this.directTransmissions,
      broadcastNodeActivity: broadcastNodeActivity ?? this.broadcastNodeActivity,
      pushTransmissions: pushTransmissions ?? this.pushTransmissions,
      acousticEchos: acousticEchos ?? this.acousticEchos,
      zoneBroadcastAlerts: zoneBroadcastAlerts ?? this.zoneBroadcastAlerts,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      theme: theme ?? this.theme,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

import 'package:flutter/material.dart';

class UserPreferences {
  static const String defaultAvatar = 'lib/assets/images/avatars/avatar_1.webp';
  static const String defaultBannerColor = '#2E4F3E';

  static const List<String> fixedAvatars = [
    'lib/assets/images/avatars/avatar_1.webp',
    'lib/assets/images/avatars/avatar_2.webp',
    'lib/assets/images/avatars/avatar_3.jpg',
    'lib/assets/images/avatars/avatar_4.jpg',
    'lib/assets/images/avatars/avatar_5.jpg',
    'lib/assets/images/avatars/avatar_6.jpg',
  ];

  static const List<String> fixedBannerColors = [
    '#2E4F3E', // Verde musgo retrô (Padrão)
    '#1E3A5F', // Azul marinho profundo
    '#5C2D46', // Vinho retrô
    '#6E3B1E', // Terracota / Âmbar escuro
    '#3D2C5E', // Roxo espacial
    '#1F4E5B', // Petróleo / Teal
    '#4A4E2E', // Oliva militar
    '#2B2B2B', // Grafite escuro
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
  final String bannerColor;

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
    this.bannerColor = defaultBannerColor,
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

  static String? extractRawBannerColor(Map<String, dynamic>? json) {
    if (json == null) return null;
    final raw = json['bannerColor'] ??
        json['corCapa'] ??
        json['banner_color'] ??
        json['headerColor'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString().trim();
    }
    return null;
  }

  static Color parseBannerColor(String? hex, {Color? fallback}) {
    final raw = (hex != null && hex.trim().isNotEmpty)
        ? hex.trim()
        : defaultBannerColor;
    final cleaned = raw.replaceAll('#', '');
    if (cleaned.length == 6) {
      final parsed = int.tryParse('FF$cleaned', radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    } else if (cleaned.length == 8) {
      final parsed = int.tryParse(cleaned, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return fallback ?? const Color(0xFF2E4F3E);
  }

  factory UserPreferences.fromJson(
    Map<String, dynamic> json, {
    String? fallbackAvatar,
    String? fallbackBannerColor,
  }) {
    final rawAvatar = extractRawAvatar(json);
    final rawBannerColor = extractRawBannerColor(json);
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
      bannerColor: rawBannerColor ?? fallbackBannerColor ?? defaultBannerColor,
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
      'bannerColor': bannerColor,
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
    String? bannerColor,
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
      bannerColor: bannerColor ?? this.bannerColor,
    );
  }
}

class UserPreferences {
  final bool privateFrequencyMode;
  final bool directTransmissions;
  final bool broadcastNodeActivity;
  final bool pushTransmissions;
  final bool acousticEchos;
  final bool zoneBroadcastAlerts;
  final bool twoFactorAuth;
  final String theme;

  const UserPreferences({
    this.privateFrequencyMode = false,
    this.directTransmissions = true,
    this.broadcastNodeActivity = true,
    this.pushTransmissions = true,
    this.acousticEchos = true,
    this.zoneBroadcastAlerts = false,
    this.twoFactorAuth = false,
    this.theme = 'RETRO_GREEN',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      privateFrequencyMode: json['privateFrequencyMode'] ?? false,
      directTransmissions: json['directTransmissions'] ?? true,
      broadcastNodeActivity: json['broadcastNodeActivity'] ?? true,
      pushTransmissions: json['pushTransmissions'] ?? true,
      acousticEchos: json['acousticEchos'] ?? true,
      zoneBroadcastAlerts: json['zoneBroadcastAlerts'] ?? false,
      twoFactorAuth: json['twoFactorAuth'] ?? false,
      theme: json['theme'] ?? 'RETRO_GREEN',
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
    );
  }
}


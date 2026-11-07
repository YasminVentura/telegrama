import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user_preferences.dart';

class UserAvatar extends StatelessWidget {
  static const List<String> presetAvatars = UserPreferences.fixedAvatars;
  static const String defaultAvatar = UserPreferences.defaultAvatar;

  final String? imageUrl;
  final String? localImagePath;
  final String name;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final bool showShadow;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.localImagePath,
    required this.name,
    this.radius = 24.0,
    this.borderColor = Colors.black,
    this.borderWidth = 2.5,
    this.showShadow = true,
    this.backgroundColor,
  });

  /// Normaliza e resolve o caminho de qualquer uma das 6 fotos de perfil fixas
  static String? resolvePresetAsset(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return null;
    final clean = rawPath.trim().replaceAll('\\', '/');

    if (presetAvatars.contains(clean)) {
      return clean;
    }
    if (clean.startsWith('lib/assets/') || clean.startsWith('assets/')) {
      return clean.startsWith('assets/') ? 'lib/$clean' : clean;
    }

    // Mapeamento pelos nomes originais ou índices
    final lower = clean.toLowerCase();
    if (lower.contains('02f7b97b') || lower == 'avatar_1' || lower == '1') {
      return presetAvatars[0];
    }
    if (lower.contains('c802ad2b') || lower == 'avatar_2' || lower == '2') {
      return presetAvatars[1];
    }
    if (lower.contains('jmxcjj') || lower == 'avatar_3' || lower == '3') {
      return presetAvatars[2];
    }
    if (lower.contains('l1cvbr') || lower == 'avatar_4' || lower == '4') {
      return presetAvatars[3];
    }
    if (lower.contains('w6z595') || lower == 'avatar_5' || lower == '5') {
      return presetAvatars[4];
    }
    if (lower.contains('xwfquj') || lower == 'avatar_6' || lower == '6') {
      return presetAvatars[5];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFFE0E0E0),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                )
              ]
            : [],
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    final String? candidate = (localImagePath != null && localImagePath!.trim().isNotEmpty)
        ? localImagePath
        : imageUrl;

    final String? presetAsset = resolvePresetAsset(candidate);
    if (presetAsset != null) {
      return Image.asset(
        presetAsset,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (localImagePath != null && localImagePath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          localImagePath!,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } else {
        return Image.file(
          File(localImagePath!),
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(
      defaultAvatar,
      fit: BoxFit.cover,
      width: radius * 2,
      height: radius * 2,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: radius * 0.8,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

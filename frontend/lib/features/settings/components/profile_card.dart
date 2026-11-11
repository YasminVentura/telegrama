import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/models/user_preferences.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class ProfileCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String bio;
  final String? location;
  final String? avatarUrl;
  final String? bannerColor;
  final String followingCount;
  final String followersCount;
  final String artifactsCount;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onDeleteUserPressed;
  final VoidCallback? onEditProfilePressed;
  final ValueChanged<String>? onAvatarSelected;
  final bool isFollowing;
  final bool isLoadingFollow;
  final bool isOwner;
  final bool canDeleteUser;

  const ProfileCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.bio,
    this.location,
    this.avatarUrl,
    this.bannerColor,
    required this.followingCount,
    required this.followersCount,
    required this.artifactsCount,
    this.onFollowPressed,
    this.onMessagePressed,
    this.onDeleteUserPressed,
    this.onEditProfilePressed,
    this.onAvatarSelected,
    this.isFollowing = false,
    this.isLoadingFollow = false,
    this.isOwner = false,
    this.canDeleteUser = false,
  });

  void _showAvatarPickerModal(BuildContext context, String currentAvatar) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: currentTheme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: currentTheme.shadowColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: currentTheme.shadowColor,
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESCOLHER FOTO DO PERFIL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: currentTheme.textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Icon(Icons.close, color: currentTheme.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecione uma das 6 imagens fixas disponíveis para o seu perfil:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: currentTheme.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: UserPreferences.fixedAvatars.map((preset) {
                    final bool isSelected =
                        (UserAvatar.resolvePresetAsset(currentAvatar) ?? currentAvatar) == preset;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onAvatarSelected?.call(preset);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? currentTheme.primaryColor
                                    : currentTheme.backgroundColor,
                                border: Border.all(
                                  color: isSelected
                                      ? currentTheme.primaryColor
                                      : currentTheme.shadowColor,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: currentTheme.shadowColor,
                                    offset: const Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: UserAvatar(
                                imageUrl: preset,
                                name: name,
                                radius: 40,
                                showShadow: false,
                                borderWidth: 1.5,
                                borderColor: currentTheme.shadowColor,
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: currentTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: currentTheme.backgroundColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(color: currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: UserRepositoryImpl.currentBannerColorNotifier,
            builder: (context, myCurrentBannerColor, _) {
              final String effectiveBannerHex = isOwner
                  ? myCurrentBannerColor
                  : (bannerColor ?? UserPreferences.defaultBannerColor);
              final Color resolvedBannerColor = UserPreferences.parseBannerColor(
                effectiveBannerHex,
                fallback: currentTheme.secondaryColor,
              );

              return Container(
                height: 180,
                decoration: BoxDecoration(
                  color: resolvedBannerColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(
                    bottom: BorderSide(color: currentTheme.shadowColor, width: 2),
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -65,
                  left: 0,
                  child: ValueListenableBuilder<String>(
                    valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                    builder: (context, myCurrentAvatar, _) {
                      final String effectiveAvatar = isOwner
                          ? myCurrentAvatar
                          : (avatarUrl ?? UserPreferences.defaultAvatar);

                      return GestureDetector(
                        onTap: isOwner ? () => _showAvatarPickerModal(context, effectiveAvatar) : null,
                        child: MouseRegion(
                          cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: currentTheme.backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: currentTheme.shadowColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                                  ],
                                ),
                                child: UserAvatar(
                                  imageUrl: effectiveAvatar,
                                  name: name,
                                  radius: 40,
                                  borderColor: currentTheme.shadowColor,
                                  borderWidth: 2,
                                  showShadow: false,
                                  backgroundColor: currentTheme.primaryColor,
                                ),
                              ),
                              if (isOwner)
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: currentTheme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: currentTheme.shadowColor, width: 2),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 14,
                                      color: currentTheme.backgroundColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              handle,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: currentTheme.primaryColor),
                            ),
                          ],
                        ),
                        if (isOwner && onEditProfilePressed != null)
                          GestureDetector(
                            onTap: onEditProfilePressed,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: currentTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: currentTheme.shadowColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: currentTheme.shadowColor,
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: currentTheme.textColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'EDIT PROFILE',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                        color: currentTheme.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (!isOwner)
                          Row(
                            children: [
                              _buildActionButton(
                                isFollowing ? 'FOLLOWING' : 'FOLLOW',
                                isPrimary: !isFollowing,
                                onTap: onFollowPressed,
                                isLoading: isLoadingFollow,
                              ),
                              if (canDeleteUser && onDeleteUserPressed != null) ...[
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: onDeleteUserPressed,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4D4D).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFF4D4D), width: 2),
                                      boxShadow: [
                                        BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.person_remove_outlined, size: 16, color: Color(0xFFFF4D4D)),
                                        SizedBox(width: 6),
                                        Text(
                                          'DELETE NODE',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF4D4D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      bio,
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: currentTheme.textColor.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _buildStatItem(followingCount, 'Following'),
                        const SizedBox(width: 24),
                        _buildStatItem(followersCount, 'Followers'),
                        const SizedBox(width: 24),
                        _buildStatItem(artifactsCount, 'Artifacts'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, {required bool isPrimary, VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? currentTheme.primaryColor : currentTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: currentTheme.shadowColor, width: 2),
          boxShadow: [
            BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isPrimary ? currentTheme.backgroundColor : currentTheme.primaryColor,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? currentTheme.backgroundColor : currentTheme.textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: currentTheme.textColor)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: currentTheme.textColor.withOpacity(0.6))),
        ],
      ),
    );
  }
}

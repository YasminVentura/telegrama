import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class PostDetailCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String content;
  final String? authorAvatarUrl;
  final String? imageUrl;
  final String? frequencyTag;
  final String exactTime;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isReposted;
  final VoidCallback? onLikePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onRepostPressed;
  final VoidCallback? onCommentPressed;

  const PostDetailCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.content,
    this.authorAvatarUrl,
    this.imageUrl,
    this.frequencyTag,
    required this.exactTime,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isReposted = false,
    this.onLikePressed,
    this.onSavePressed,
    this.onRepostPressed,
    this.onCommentPressed,
  });

  void _openUserProfile(BuildContext context) {
    final bool isMe = UserRepositoryImpl.isCurrentUser(
      handle,
      authorName: name,
    );
    final String cleanNodeId = handle.replaceAll('@', '').trim();
    if (cleanNodeId.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: currentTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: currentTheme.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: currentTheme.textColor),
            title: Text(
              name,
              style: TextStyle(
                color: currentTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ProfileScreen(
            currentTheme: currentTheme,
            nodeId: isMe ? null : cleanNodeId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: currentTheme.shadowColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openUserProfile(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                          builder: (context, currentMyAvatar, _) {
                            final bool isMyPost = UserRepositoryImpl.isCurrentUser(
                              handle,
                              authorName: name,
                            );
                            final String effectiveAvatar = isMyPost
                                ? currentMyAvatar
                                : ((authorAvatarUrl != null && authorAvatarUrl!.isNotEmpty)
                                    ? authorAvatarUrl!
                                    : UserAvatar.defaultAvatar);

                            return UserAvatar(
                              imageUrl: effectiveAvatar,
                              name: name,
                              radius: 26,
                              borderColor: currentTheme.shadowColor,
                              borderWidth: 2,
                              backgroundColor: currentTheme.primaryColor,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: currentTheme.textColor,
                                ),
                              ),
                              Text(
                                handle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: currentTheme.textColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: 20,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: currentTheme.textColor,
            ),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentTheme.shadowColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: currentTheme.shadowColor,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
                image: DecorationImage(
                  image: imageUrl!.startsWith('http')
                      ? NetworkImage(imageUrl!) as ImageProvider
                      : AssetImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            exactTime,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: currentTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: currentTheme.shadowColor, thickness: 2, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('$likesCount', 'Likes'),
              const SizedBox(width: 24),
              _buildStatItem('$commentsCount', 'Comments'),
              const SizedBox(width: 24),
              _buildStatItem('$repostsCount', 'Reposts'),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: currentTheme.shadowColor, thickness: 2, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionIcon(
                Icons.chat_bubble_outline,
                onTap: onCommentPressed,
                isActive: false,
                activeColor: currentTheme.primaryColor,
              ),
              _buildActionIcon(
                Icons.repeat,
                onTap: onRepostPressed,
                isActive: isReposted,
                activeColor: currentTheme.primaryColor,
              ),
              _buildActionIcon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                onTap: onLikePressed,
                isActive: isLiked,
                activeColor: Colors.redAccent,
              ),
              _buildActionIcon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                onTap: onSavePressed,
                isActive: isSaved,
                activeColor: currentTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: currentTheme.textColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: currentTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(
    IconData icon, {
    VoidCallback? onTap,
    required bool isActive,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 24,
            color: isActive
                ? activeColor
                : currentTheme.textColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

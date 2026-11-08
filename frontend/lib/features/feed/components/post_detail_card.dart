import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class PostDetailCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String content;
  final String? authorAvatarUrl;
  final String? imageUrl;
  final String frequencyTag;
  final String exactTime;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;

  const PostDetailCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.content,
    this.authorAvatarUrl,
    this.imageUrl,
    required this.frequencyTag,
    required this.exactTime,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
  });

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
              ValueListenableBuilder<String>(
                valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                builder: (context, currentMyAvatar, _) {
                  final bool isMyPost = UserRepositoryImpl.isCurrentUser(
                    handle,
                    authorName: name,
                  );
                  final String effectiveAvatar = isMyPost
                      ? currentMyAvatar
                      : ((authorAvatarUrl != null &&
                              authorAvatarUrl!.isNotEmpty)
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                    ),
                    Text(
                      handle,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: currentTheme.textColor.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  frequencyTag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w500, color: currentTheme.textColor),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentTheme.shadowColor, width: 2),
                boxShadow: [
                  BoxShadow(color: currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: currentTheme.textColor.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          Divider(color: currentTheme.shadowColor, thickness: 2, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem('$repostsCount', 'Reposts'),
              const SizedBox(width: 24),
              _buildStatItem('$likesCount', 'Likes'),
              const SizedBox(width: 24),
              _buildStatItem('$commentsCount', 'Comments'),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: currentTheme.shadowColor, thickness: 2, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionIcon(Icons.chat_bubble_outline, currentTheme.secondaryColor),
              _buildActionIcon(Icons.repeat, Colors.green),
              _buildActionIcon(Icons.favorite_border, Colors.red),
              _buildActionIcon(Icons.bookmark_border, currentTheme.primaryColor),
              _buildActionIcon(Icons.share_outlined, currentTheme.textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Row(
      children: [
        Text(count, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: currentTheme.textColor)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14, color: currentTheme.textColor.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, Color hoverColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: currentTheme.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: Icon(icon, size: 26, color: currentTheme.textColor.withValues(alpha: 0.7)),
      ),
    );
  }
}

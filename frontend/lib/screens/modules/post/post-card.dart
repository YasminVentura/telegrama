import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';

class PostCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String timeAgo;
  final String content;
  final String? imageUrl; 
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onRepostPressed;

  const PostCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    this.onLikePressed,
    this.onCommentPressed,
    this.onRepostPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: currentTheme.shadowColor,
            offset: const Offset(4, 4), 
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: currentTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: currentTheme.shadowColor, width: 2),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: currentTheme.secondaryColor.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$handle • $timeAgo',
                    style: TextStyle(
                      fontSize: 12,
                      color: currentTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            content,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: currentTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentTheme.shadowColor, width: 2),
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: currentTheme.shadowColor.withOpacity(0.3), thickness: 1.5, height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildInteractionButton(
                icon: Icons.favorite_border,
                count: likesCount,
                color: currentTheme.primaryColor,
                onTap: onLikePressed,
              ),
              const SizedBox(width: 24),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline,
                count: commentsCount,
                color: currentTheme.textColor,
                onTap: onCommentPressed,
              ),
              const SizedBox(width: 24),
              _buildInteractionButton(
                icon: Icons.repeat,
                count: repostsCount,
                color: currentTheme.textColor,
                onTap: onRepostPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
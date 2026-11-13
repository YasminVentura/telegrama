import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class CommentItemComponent extends StatelessWidget {
  final AppTheme currentTheme;
  final String commentId;
  final String name;
  final String handle;
  final String? authorAvatarUrl;
  final String content;
  final String timeAgo;
  final int likesCount;
  final bool isLiked;
  final bool isLast;
  final int depth;
  final List<Map<String, dynamic>> replies;
  final void Function(String commentId, String handle)? onReplyPressed;
  final void Function(String commentId)? onLikePressed;

  const CommentItemComponent({
    super.key,
    required this.currentTheme,
    this.commentId = '',
    required this.name,
    required this.handle,
    this.authorAvatarUrl,
    required this.content,
    required this.timeAgo,
    required this.likesCount,
    this.isLiked = false,
    this.isLast = false,
    this.depth = 0,
    this.replies = const [],
    this.onReplyPressed,
    this.onLikePressed,
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
    final bool hasReplies = replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Column(
                children: [
                  GestureDetector(
                    onTap: () => _openUserProfile(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: ValueListenableBuilder<String>(
                          valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                          builder: (context, currentMyAvatar, _) {
                            final bool isMyComment = UserRepositoryImpl.isCurrentUser(
                              handle,
                              authorName: name,
                            );
                            final String effectiveAvatar = isMyComment
                                ? currentMyAvatar
                                : ((authorAvatarUrl != null &&
                                        authorAvatarUrl!.isNotEmpty)
                                    ? authorAvatarUrl!
                                    : UserAvatar.defaultAvatar);

                            return UserAvatar(
                              imageUrl: effectiveAvatar,
                              name: name,
                              radius: depth > 0 ? 15 : 18,
                              borderColor: currentTheme.shadowColor,
                              borderWidth: 1.5,
                              backgroundColor: currentTheme.secondaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (!isLast || hasReplies)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: currentTheme.shadowColor.withValues(alpha: 0.3),
                        margin: const EdgeInsets.only(top: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: currentTheme.shadowColor.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => _openUserProfile(context),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: depth > 0 ? 14 : 15,
                                          fontWeight: FontWeight.w900,
                                          color: currentTheme.textColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      handle,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.textColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: currentTheme.textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: depth > 0 ? 14 : 15,
                          height: 1.4,
                          color: currentTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: commentId.isNotEmpty && onReplyPressed != null
                                ? () => onReplyPressed!(commentId, handle)
                                : null,
                            child: _buildActionIcon(
                              Icons.reply_rounded,
                              'Responder',
                              color: currentTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: commentId.isNotEmpty && onLikePressed != null
                                ? () => onLikePressed!(commentId)
                                : null,
                            child: _buildActionIcon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              '$likesCount',
                              color: isLiked
                                  ? Colors.redAccent
                                  : currentTheme.textColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasReplies)
          Padding(
            padding: EdgeInsets.only(left: depth < 3 ? 28.0 : 12.0),
            child: Column(
              children: List.generate(replies.length, (idx) {
                final reply = replies[idx];
                final List<Map<String, dynamic>> childReplies =
                    (reply['replies'] is List)
                        ? (reply['replies'] as List)
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList()
                        : const [];
                return CommentItemComponent(
                  key: ValueKey(reply['id'] ?? '${commentId}_reply_$idx'),
                  currentTheme: currentTheme,
                  commentId: reply['id']?.toString() ?? '',
                  name: reply['authorName'] ?? 'Node Anônimo',
                  handle: reply['authorHandle'] ?? '@node',
                  authorAvatarUrl: reply['authorAvatarUrl']?.toString(),
                  content: reply['content'] ?? '',
                  timeAgo: reply['timeAgo'] ?? 'Agora',
                  likesCount: (reply['likesCount'] ?? 0) as int,
                  isLiked: reply['curtidoPeloUsuario'] == true,
                  isLast: idx == replies.length - 1,
                  depth: depth + 1,
                  replies: childReplies,
                  onReplyPressed: onReplyPressed,
                  onLikePressed: onLikePressed,
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, {Color? color}) {
    final effectiveColor = color ?? currentTheme.textColor.withValues(alpha: 0.6);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

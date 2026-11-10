import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class PostCard extends StatefulWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String timeAgo;
  final String content;
  final String? authorAvatarUrl;
  final String? imageUrl;
  final String? frequencyTag;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isReposted;
  final bool showRepostBadge;
  final String? repostedByLabel;
  final VoidCallback? onLikePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onRepostPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;
  final bool canDelete;

  const PostCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.timeAgo,
    required this.content,
    this.authorAvatarUrl,
    this.imageUrl,
    this.frequencyTag,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isReposted = false,
    this.showRepostBadge = false,
    this.repostedByLabel,
    this.onLikePressed,
    this.onSavePressed,
    this.onCommentPressed,
    this.onRepostPressed,
    this.onDeletePressed,
    this.onTap,
    this.onProfileTap,
    this.canDelete = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;
  late bool _isSaved;
  late bool _isReposted;
  late int _repostsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;
    _isSaved = widget.isSaved;
    _isReposted = widget.isReposted;
    _repostsCount = widget.repostsCount;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked || oldWidget.likesCount != widget.likesCount) {
      _isLiked = widget.isLiked;
      _likesCount = widget.likesCount;
    }
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
    if (oldWidget.isReposted != widget.isReposted ||
        oldWidget.repostsCount != widget.repostsCount) {
      _isReposted = widget.isReposted;
      _repostsCount = widget.repostsCount;
    }
  }

  void _openUserProfile(BuildContext context) {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
      return;
    }
    final bool isMe = UserRepositoryImpl.isCurrentUser(
      widget.handle,
      authorName: widget.name,
    );
    final String cleanNodeId = widget.handle.replaceAll('@', '').trim();
    if (cleanNodeId.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: widget.currentTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: widget.currentTheme.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: widget.currentTheme.textColor),
            title: Text(
              widget.name,
              style: TextStyle(
                color: widget.currentTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ProfileScreen(
            currentTheme: widget.currentTheme,
            nodeId: isMe ? null : cleanNodeId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentLikes = _likesCount;
    final int currentReposts = _repostsCount;
    final VoidCallback? cardTapAction = widget.onTap ?? widget.onCommentPressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cardTapAction,
      child: MouseRegion(
        cursor: cardTapAction != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.currentTheme.shadowColor,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showRepostBadge) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.currentTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: widget.currentTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.repostedByLabel ?? 'REPOSTADO',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: widget.currentTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openUserProfile(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                            builder: (context, currentMyAvatar, _) {
                              final bool isMyPost = UserRepositoryImpl.isCurrentUser(
                                widget.handle,
                                authorName: widget.name,
                              );
                              final String effectiveAvatar = isMyPost
                                  ? currentMyAvatar
                                  : ((widget.authorAvatarUrl != null &&
                                          widget.authorAvatarUrl!.isNotEmpty)
                                      ? widget.authorAvatarUrl!
                                      : UserAvatar.defaultAvatar);

                              return UserAvatar(
                                imageUrl: effectiveAvatar,
                                name: widget.name,
                                radius: 18,
                                borderColor: widget.currentTheme.shadowColor,
                                borderWidth: 2,
                                backgroundColor: widget.currentTheme.primaryColor,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: widget.currentTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.handle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: widget.currentTheme.textColor.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.timeAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.currentTheme.textColor.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      if (widget.canDelete && widget.onDeletePressed != null) ...[
                        GestureDetector(
                          onTap: widget.onDeletePressed,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4D4D).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFF4D4D), width: 1.5),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Color(0xFFFF4D4D),
                              ),
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
                widget.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: widget.currentTheme.textColor,
                ),
              ),

              if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.currentTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                    image: DecorationImage(
                      image: widget.imageUrl!.startsWith('http')
                          ? NetworkImage(widget.imageUrl!) as ImageProvider
                          : AssetImage(widget.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Divider(color: widget.currentTheme.shadowColor.withOpacity(0.3), height: 1),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _PostInteractionButton(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        count: '$currentLikes',
                        isActive: _isLiked,
                        activeColor: Colors.redAccent,
                        primaryColor: widget.currentTheme.primaryColor,
                        shadowColor: widget.currentTheme.shadowColor,
                        backgroundColor: widget.currentTheme.backgroundColor,
                        textColor: widget.currentTheme.textColor,
                        onTap: () {
                          if (!UserRepositoryImpl.isLoggedIn) {
                            if (widget.onLikePressed != null) widget.onLikePressed!();
                            return;
                          }
                          setState(() {
                            _isLiked = !_isLiked;
                            _likesCount += _isLiked ? 1 : -1;
                            if (_likesCount < 0) _likesCount = 0;
                          });
                          if (widget.onLikePressed != null) widget.onLikePressed!();
                        },
                      ),
                      const SizedBox(width: 16),
                      _PostInteractionButton(
                        icon: Icons.chat_bubble_outline,
                        count: '${widget.commentsCount}',
                        isActive: false,
                        activeColor: widget.currentTheme.primaryColor,
                        primaryColor: widget.currentTheme.primaryColor,
                        shadowColor: widget.currentTheme.shadowColor,
                        backgroundColor: widget.currentTheme.backgroundColor,
                        textColor: widget.currentTheme.textColor,
                        onTap: widget.onCommentPressed,
                      ),
                      const SizedBox(width: 16),
                      _PostInteractionButton(
                        icon: Icons.repeat,
                        count: '$currentReposts',
                        isActive: _isReposted,
                        activeColor: widget.currentTheme.primaryColor,
                        primaryColor: widget.currentTheme.primaryColor,
                        shadowColor: widget.currentTheme.shadowColor,
                        backgroundColor: widget.currentTheme.backgroundColor,
                        textColor: widget.currentTheme.textColor,
                        onTap: () {
                          if (!UserRepositoryImpl.isLoggedIn) {
                            if (widget.onRepostPressed != null) widget.onRepostPressed!();
                            return;
                          }
                          setState(() {
                            _isReposted = !_isReposted;
                            _repostsCount += _isReposted ? 1 : -1;
                            if (_repostsCount < 0) _repostsCount = 0;
                          });
                          if (widget.onRepostPressed != null) widget.onRepostPressed!();
                        },
                      ),
                    ],
                  ),
                  _BookmarkButton(
                    isSaved: _isSaved,
                    primaryColor: widget.currentTheme.primaryColor,
                    shadowColor: widget.currentTheme.shadowColor,
                    backgroundColor: widget.currentTheme.backgroundColor,
                    textColor: widget.currentTheme.textColor,
                    onTap: () {
                      if (!UserRepositoryImpl.isLoggedIn) {
                        if (widget.onSavePressed != null) widget.onSavePressed!();
                        return;
                      }
                      setState(() {
                        _isSaved = !_isSaved;
                      });
                      if (widget.onSavePressed != null) widget.onSavePressed!();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostInteractionButton extends StatefulWidget {
  final IconData icon;
  final String count;
  final bool isActive;
  final Color activeColor;
  final Color primaryColor;
  final Color shadowColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _PostInteractionButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.primaryColor,
    required this.shadowColor,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  @override
  State<_PostInteractionButton> createState() => _PostInteractionButtonState();
}

class _PostInteractionButtonState extends State<_PostInteractionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color currentBorderColor = widget.isActive
        ? widget.activeColor
        : (_isHovered ? widget.primaryColor : widget.shadowColor.withOpacity(0.4));

    final Color currentFgColor = widget.isActive
        ? widget.activeColor
        : (_isHovered ? widget.primaryColor : widget.textColor.withOpacity(0.8));

    final Color currentBgColor = widget.isActive
        ? widget.activeColor.withOpacity(0.15)
        : (_isHovered ? widget.primaryColor.withOpacity(0.08) : widget.backgroundColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: currentBgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: currentBorderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: currentFgColor),
              const SizedBox(width: 6),
              Text(
                widget.count,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: currentFgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatefulWidget {
  final bool isSaved;
  final Color primaryColor;
  final Color shadowColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _BookmarkButton({
    required this.isSaved,
    required this.primaryColor,
    required this.shadowColor,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color fgColor = widget.isSaved
        ? widget.primaryColor
        : (_isHovered ? widget.primaryColor : widget.textColor.withOpacity(0.6));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isHovered ? widget.primaryColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
            size: 20,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}

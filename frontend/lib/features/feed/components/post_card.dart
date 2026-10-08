import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class PostCard extends StatefulWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String timeAgo;
  final String content;
  final String? imageUrl; 
  final String? frequencyTag;
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
    this.frequencyTag,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    this.onLikePressed,
    this.onCommentPressed,
    this.onRepostPressed,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isReposted = false;
  bool _isSaved = false;

  String _getInitials(String text) {
    List<String> words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'SV';
  }

  @override
  Widget build(BuildContext context) {
    int currentLikes = widget.likesCount + (_isLiked ? 1 : 0);
    int currentReposts = widget.repostsCount + (_isReposted ? 1 : 0);

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: widget.currentTheme.primaryColor,
                      child: Text(
                        _getInitials(widget.name),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.currentTheme.backgroundColor),
                      ),
                    ),
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
              
              if (widget.frequencyTag != null && widget.frequencyTag!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                  ),
                  child: Text(
                    widget.frequencyTag!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.currentTheme.shadowColor),
                  ),
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
                      setState(() {
                        _isLiked = !_isLiked;
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
                      setState(() {
                        _isReposted = !_isReposted;
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
                  setState(() {
                    _isSaved = !_isSaved;
                  });
                },
              ),
            ],
          ),
        ],
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
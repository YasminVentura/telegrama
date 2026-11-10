import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/feed/components/post_attachment_button.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class SendPostWidget extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(String) onPostSubmitted;
  final String? avatarUrl;
  final String? userName;

  const SendPostWidget({
    super.key,
    required this.currentTheme,
    required this.onPostSubmitted,
    this.avatarUrl,
    this.userName,
  });

  @override
  State<SendPostWidget> createState() => _SendPostWidgetState();
}

class _SendPostWidgetState extends State<SendPostWidget> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  bool _isHoveredSend = false;
  bool _isSending = false;

  late final AnimationController _planeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500), 
  );

  late final Animation<double> _slideAnimation = Tween<double>(begin: 0.0, end: 120.0).animate(
    CurvedAnimation(parent: _planeController, curve: Curves.easeInOut),
  );

  late final Animation<double> _planeFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(parent: _planeController, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
  );

  late final Animation<double> _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(parent: _planeController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
  );

  @override
  void dispose() {
    _textController.dispose();
    _planeController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_textController.text.trim().isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _planeController.forward().then((_) {
      widget.onPostSubmitted(_textController.text);
      _textController.clear();

      _planeController.reset();
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                builder: (context, currentAvatar, _) {
                  final effectiveAvatar = (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                      ? widget.avatarUrl!
                      : currentAvatar;
                  final effectiveName = (widget.userName != null && widget.userName!.isNotEmpty)
                      ? widget.userName!
                      : UserRepositoryImpl.currentUserNameNotifier.value;

                  return UserAvatar(
                    imageUrl: effectiveAvatar,
                    name: effectiveName,
                    radius: 20,
                    borderColor: widget.currentTheme.shadowColor,
                    borderWidth: 2,
                    backgroundColor: widget.currentTheme.secondaryColor,
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 2,
                  minLines: 1,
                  style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Post a new wave into the retroverse...',
                    hintStyle: TextStyle(fontSize: 14, color: widget.currentTheme.textColor.withOpacity(0.6)),
                    filled: true,
                    fillColor: widget.currentTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: widget.currentTheme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  PostAttachmentButton(
                    icon: Icons.sentiment_satisfied_outlined,
                    onTap: () {},
                    primaryColor: widget.currentTheme.primaryColor,
                    shadowColor: widget.currentTheme.shadowColor,
                    backgroundColor: widget.currentTheme.backgroundColor,
                  ),
                ],
              ),
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredSend = true),
                onExit: (_) => setState(() => _isHoveredSend = false),
                child: GestureDetector(
                  onTap: _handleSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentTheme.shadowColor,
                          offset: _isHoveredSend ? const Offset(1, 1) : const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _planeController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_slideAnimation.value, 0),
                              child: Opacity(
                                opacity: _planeFadeAnimation.value,
                                child: Icon(
                                  Icons.send_outlined,
                                  color: widget.currentTheme.backgroundColor,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _planeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textFadeAnimation.value,
                              child: Text(
                                'SEND POST',
                                style: TextStyle(
                                  color: widget.currentTheme.backgroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

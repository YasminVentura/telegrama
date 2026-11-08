import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class ReplyInputWidget extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(String text) onReplySubmitted;
  final String? replyingToHandle;
  final VoidCallback? onCancelReply;
  final FocusNode? focusNode;

  const ReplyInputWidget({
    super.key,
    required this.currentTheme,
    required this.onReplySubmitted,
    this.replyingToHandle,
    this.onCancelReply,
    this.focusNode,
  });

  @override
  State<ReplyInputWidget> createState() => _ReplyInputWidgetState();
}

class _ReplyInputWidgetState extends State<ReplyInputWidget> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onReplySubmitted(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.currentTheme.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.replyingToHandle != null &&
                  widget.replyingToHandle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.currentTheme.shadowColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: widget.currentTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Respondendo a ${widget.replyingToHandle}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme.textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.onCancelReply,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: widget.currentTheme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                    builder: (context, currentAvatar, _) {
                      return UserAvatar(
                        imageUrl: currentAvatar,
                        name: UserRepositoryImpl.currentUserNameNotifier.value,
                        radius: 20,
                        borderColor: widget.currentTheme.shadowColor,
                        borderWidth: 2,
                        backgroundColor: widget.currentTheme.primaryColor,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.currentTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.currentTheme.shadowColor,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: widget.focusNode,
                        onSubmitted: (_) => _submit(),
                        style: TextStyle(
                          color: widget.currentTheme.textColor,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: widget.replyingToHandle != null
                              ? 'Responder a ${widget.replyingToHandle}...'
                              : 'Transmitir comentário...',
                          hintStyle: TextStyle(
                            color: widget.currentTheme.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _submit,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: widget.currentTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.currentTheme.shadowColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.currentTheme.shadowColor,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Comentar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: widget.currentTheme.backgroundColor,
                          ),
                        ),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class ReplyInputWidget extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(String text) onReplySubmitted;

  const ReplyInputWidget({
    super.key,
    required this.currentTheme,
    required this.onReplySubmitted,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        border: Border(top: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: widget.currentTheme.primaryColor,
                child: Text('ME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.currentTheme.backgroundColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  ),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: widget.currentTheme.textColor, fontSize: 15),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Transmit your reply...',
                      hintStyle: TextStyle(color: widget.currentTheme.textColor.withValues(alpha: 0.5)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: Text(
                      'Reply',
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
        ),
      ),
    );
  }
}

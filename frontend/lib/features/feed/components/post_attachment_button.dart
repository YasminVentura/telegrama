import 'package:flutter/material.dart';

class PostAttachmentButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color shadowColor;
  final Color backgroundColor;

  const PostAttachmentButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    required this.shadowColor,
    required this.backgroundColor,
  });

  @override
  State<PostAttachmentButton> createState() => _PostAttachmentButtonState();
}

class _PostAttachmentButtonState extends State<PostAttachmentButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? widget.primaryColor.withOpacity(0.15) : widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.shadowColor, width: 1.5),
          ),
          child: Icon(
            widget.icon,
            color: _isHovered ? widget.primaryColor : widget.shadowColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

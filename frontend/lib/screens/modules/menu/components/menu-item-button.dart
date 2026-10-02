import 'package:flutter/material.dart';

class CustomMenuItemButton extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final bool isActive;
  final bool hasIndicator;
  final Color primaryColor;
  final Color textColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const CustomMenuItemButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.isActive,
    required this.hasIndicator,
    required this.primaryColor,
    required this.textColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<CustomMenuItemButton> createState() => _CustomMenuItemButtonState();
}

class _CustomMenuItemButtonState extends State<CustomMenuItemButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    if (widget.isActive) {
      backgroundColor = widget.primaryColor.withOpacity(0.12);
    } else if (_isHovered) {
      backgroundColor = widget.shadowColor.withOpacity(0.08);
    }

    Color contentColor = widget.isActive ? widget.primaryColor : widget.textColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive 
                ? Border.all(color: widget.primaryColor, width: 1.5) 
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                color: contentColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w600,
                    color: contentColor,
                  ),
                ),
              ),
              if (widget.hasIndicator)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
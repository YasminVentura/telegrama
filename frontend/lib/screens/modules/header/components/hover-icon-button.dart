import 'package:flutter/material.dart';

class HoverIconButton extends StatefulWidget {
  final Widget icon;
  final bool hasNotification;
  final Color primaryColor;
  final Color shadowColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final String? destinationRoute;
  final Function(String route)? onNavigate;

  const HoverIconButton({
    super.key,
    required this.icon,
    this.hasNotification = false,
    required this.primaryColor,
    required this.shadowColor,
    required this.backgroundColor,
    this.onTap,
    this.destinationRoute,
    this.onNavigate,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else if (widget.destinationRoute != null && widget.onNavigate != null) {
            widget.onNavigate!(widget.destinationRoute!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isHovered ? widget.primaryColor : widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.shadowColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildThemedIcon(),
              if (widget.hasNotification)
                Positioned(
                  right: 3, 
                  bottom: 3, 
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red, 
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.backgroundColor, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemedIcon() {
    final Color targetIconColor = _isHovered ? widget.backgroundColor : widget.shadowColor;

    if (widget.icon is Icon) {
      final Icon originalIcon = widget.icon as Icon;
      return Icon(
        originalIcon.icon,
        color: targetIconColor,
        size: originalIcon.size ?? 20,
      );
    }

    return widget.icon;
  }
}
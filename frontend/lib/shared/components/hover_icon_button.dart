import 'package:flutter/material.dart';

class HoverIconButton extends StatefulWidget {
  final Widget icon;
  final bool hasNotification;
  final int? notificationCount;
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
    this.notificationCount,
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
            clipBehavior: Clip.none,
            children: [
              _buildThemedIcon(),
              if (widget.hasNotification)
                Positioned(
                  right: widget.notificationCount != null ? -4 : 3,
                  top: widget.notificationCount != null ? -4 : null,
                  bottom: widget.notificationCount != null ? null : 3,
                  child: Container(
                    padding: widget.notificationCount != null ? const EdgeInsets.all(2) : null,
                    width: widget.notificationCount != null ? 18 : 10,
                    height: widget.notificationCount != null ? 18 : 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.backgroundColor, width: 1.5),
                    ),
                    child: widget.notificationCount != null
                        ? Center(
                            child: Text(
                              widget.notificationCount! > 9 ? '9+' : widget.notificationCount.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          )
                        : null,
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

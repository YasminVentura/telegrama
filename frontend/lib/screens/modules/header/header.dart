import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';
import 'components/hover-icon-button.dart';

class HeaderWidget extends StatefulWidget implements PreferredSizeWidget {
  final AppTheme currentTheme;

  const HeaderWidget({super.key, required this.currentTheme});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.currentTheme.primaryColor,
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(Icons.waves, color: widget.currentTheme.backgroundColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Telegrama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: widget.currentTheme.textColor,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 400,
            height: 40,
            child: TextField(
              style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search channels, radio stations, waves...',
                hintStyle: TextStyle(fontSize: 14, color: widget.currentTheme.textColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: widget.currentTheme.textColor, size: 20),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.backgroundColor,
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⌘K',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor),
                  ),
                ),
                filled: true,
                fillColor: widget.currentTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.currentTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          Row(
            children: [
              HoverIconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: widget.currentTheme.shadowColor,
                  size: 20,
                ),
                hasNotification: true,
                primaryColor: widget.currentTheme.primaryColor,
                shadowColor: widget.currentTheme.shadowColor,
                backgroundColor: widget.currentTheme.backgroundColor,
                destinationRoute: 'NotificationsScreen',
                onNavigate: (route) {
                  // Implement navigation logic here
                  print('Navigating to $route');
                },
              ),
              const SizedBox(width: 12),
              HoverIconButton(
                icon: Icon(
                  Icons.mail_outline,
                  color: widget.currentTheme.shadowColor,
                  size: 20,
                ),
                primaryColor: widget.currentTheme.primaryColor,
                shadowColor: widget.currentTheme.shadowColor,
                backgroundColor: widget.currentTheme.backgroundColor,
                destinationRoute: 'ChatScreen',
                onNavigate: (route) {
                  // Implement navigation logic here
                  print('Navigating to $route');
                },
              ),
              const SizedBox(width: 12),
              HoverIconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: widget.currentTheme.shadowColor,
                  size: 20,
                ),
                primaryColor: widget.currentTheme.primaryColor,
                shadowColor: widget.currentTheme.shadowColor,
                backgroundColor: widget.currentTheme.backgroundColor,
                destinationRoute: 'SettingsScreen',
                onNavigate: (route) {
                  // Implement navigation logic here
                  print('Navigating to $route');
                },
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.currentTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: widget.currentTheme.secondaryColor.withOpacity(0.8),
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
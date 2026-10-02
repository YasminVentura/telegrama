import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';
import './components/menu-item-button.dart';

class MenuWidget extends StatefulWidget {
  final AppTheme currentTheme;
  final String activeRoute; 
  final Function(String) onItemSelected;

  const MenuWidget({
    super.key,
    required this.currentTheme,
    this.activeRoute = 'Home Feed',
    required this.onItemSelected,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            title: 'Home Feed',
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            title: 'Explore Zones',
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            title: 'Wave Chats',
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.bookmark_border,
            activeIcon: Icons.bookmark,
            title: 'Saved Reels',
          ),
          const SizedBox(height: 16),
          Divider(color: widget.currentTheme.shadowColor, thickness: 2, height: 24),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            title: 'My Profile',
            hasIndicator: true, 
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    bool hasIndicator = false,
  }) {
    final bool isActive = widget.activeRoute == title;

    return CustomMenuItemButton(
      icon: icon,
      activeIcon: activeIcon,
      title: title,
      isActive: isActive,
      hasIndicator: hasIndicator,
      primaryColor: widget.currentTheme.primaryColor,
      textColor: widget.currentTheme.textColor,
      shadowColor: widget.currentTheme.shadowColor,
      onTap: () {
        widget.onItemSelected(title);
      },
    );
  }
}
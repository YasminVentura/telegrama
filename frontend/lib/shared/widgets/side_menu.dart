import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/menu_item_button.dart';

class MenuWidget extends StatefulWidget {
  final AppTheme currentTheme;
  final String activeRoute;
  final Function(String) onItemSelected;
  final VoidCallback? onLogout;

  const MenuWidget({
    super.key,
    required this.currentTheme,
    this.activeRoute = 'Feed Inicial',
    required this.onItemSelected,
    this.onLogout,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: UserRepositoryImpl.isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        final bool autenticado = isLoggedIn || UserRepositoryImpl.isLoggedIn;

        return Container(
          width: 240,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.currentTheme.shadowColor,
              width: 2,
            ),
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
                title: 'Feed Inicial',
              ),
              const SizedBox(height: 16),
              Divider(
                color: widget.currentTheme.shadowColor,
                thickness: 2,
                height: 24,
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                title: 'Meu Perfil',
                hasIndicator: autenticado,
              ),
              if (autenticado && widget.onLogout != null) ...[
                const SizedBox(height: 12),
                CustomMenuItemButton(
                  icon: Icons.logout,
                  activeIcon: Icons.logout,
                  title: 'Sair',
                  isActive: false,
                  hasIndicator: false,
                  primaryColor: const Color(0xFFFF4D4D),
                  textColor: widget.currentTheme.textColor,
                  shadowColor: widget.currentTheme.shadowColor,
                  onTap: widget.onLogout!,
                ),
              ],
            ],
          ),
        );
      },
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

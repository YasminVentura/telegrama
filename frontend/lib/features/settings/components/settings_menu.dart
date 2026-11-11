import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class SettingsMenu extends StatelessWidget {
  final AppTheme currentTheme;
  final String activeRoute;
  final Function(String) onItemSelected;

  const SettingsMenu({
    super.key,
    required this.currentTheme,
    required this.activeRoute,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Perfil & Conta', 'icon': Icons.person_outline},
      {'title': 'Aparência', 'icon': Icons.palette_outlined},
      {'title': 'Privacidade', 'icon': Icons.lock_outline},
      {'title': 'Segurança', 'icon': Icons.shield_outlined},
      {'title': 'Notificações', 'icon': Icons.notifications_outlined},
      {'title': 'Ajuda', 'icon': Icons.help_outline},
    ];

    return Column(
      children: [
        // Container principal do menu
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: currentTheme.shadowColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: menuItems.map((item) {
              bool isSelected = activeRoute == item['title'];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onItemSelected(item['title']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? currentTheme.primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? currentTheme.primaryColor
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'],
                          size: 18,
                          color: isSelected
                              ? currentTheme.primaryColor
                              : currentTheme.textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isSelected
                                  ? currentTheme.primaryColor
                                  : currentTheme.textColor,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: currentTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ), // Card de status do sinal na parte inferior
      ],
    );
  }
}

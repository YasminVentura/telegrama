import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class AppearanceSettingsContent extends StatelessWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;

  const AppearanceSettingsContent({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<AppTheme> availableThemes = [
      AppTheme.retroGreen,
      AppTheme.cyberpunk,
      AppTheme.synthwave,
      AppTheme.hacker,
      AppTheme.espresso,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(color: currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance & Frequencies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: currentTheme.textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Tune the visual color palette and vibe of your retroverse interface.',
            style: TextStyle(fontSize: 12.5, color: currentTheme.textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: availableThemes.map((theme) {
              bool isSelected = currentTheme.name == theme.name;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onThemeChanged(theme),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : currentTheme.shadowColor,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentTheme.shadowColor,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              theme.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: theme.textColor,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, size: 10, color: theme.backgroundColor),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(width: 24, height: 24, decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle, border: Border.all(color: currentTheme.shadowColor, width: 1.5))),
                            const SizedBox(width: 8),
                            Container(width: 24, height: 24, decoration: BoxDecoration(color: theme.secondaryColor, shape: BoxShape.circle, border: Border.all(color: currentTheme.shadowColor, width: 1.5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
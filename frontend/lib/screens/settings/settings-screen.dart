import 'package:flutter/material.dart';
import '../../themes/app_themes.dart';
import 'components/settings-menu.dart';
import 'components/profile-settings.dart';
import 'components/appearance-settings.dart';
import 'components/privacy-settings.dart';
import 'components/security-settings.dart';
import 'components/notifications-settings.dart';

class SettingsScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeSettingsRoute = 'Profile & Account';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: widget.currentTheme.textColor),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Feed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'CONTROL ROOM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: widget.currentTheme.textColor,
                    ),
                  ),
                  Text(
                    'NODE ID • SAS_VANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.currentTheme.textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Edit your identity, node coordinates and account frequency.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 240,
                    child: SettingsMenu(
                      currentTheme: widget.currentTheme,
                      activeRoute: _activeSettingsRoute,
                      onItemSelected: (route) {
                        setState(() {
                          _activeSettingsRoute = route;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  Expanded(
                    child: _buildSelectedContent(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_activeSettingsRoute) {
      case 'Appearance':
        return AppearanceSettingsContent(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
        );
      case 'Privacy':
        return PrivacySettingsContent(currentTheme: widget.currentTheme);
      case 'Security':
        return SecuritySettingsContent(currentTheme: widget.currentTheme);
      case 'Notifications':
        return NotificationsSettingsContent(currentTheme: widget.currentTheme);
      case 'Help center':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
            boxShadow: [
              BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Terminal Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
              ),
              const SizedBox(height: 12),
              Text(
                'For signal troubleshooting and frequency calibration support, contact terminal command at support@telegrama.zone.',
                style: TextStyle(fontSize: 13, color: widget.currentTheme.textColor.withOpacity(0.7)),
              ),
            ],
          ),
        );
      case 'Profile & Account':
      default:
        return ProfileSettingsContent(currentTheme: widget.currentTheme);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/settings/components/settings_menu.dart';
import 'package:frontend/features/settings/components/profile_settings.dart';
import 'package:frontend/features/settings/components/appearance_settings.dart';
import 'package:frontend/features/settings/components/privacy_settings.dart';
import 'package:frontend/features/settings/components/security_settings.dart';
import 'package:frontend/features/settings/components/notifications_settings.dart';

class SettingsScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;
  final VoidCallback onBack;
  final VoidCallback? onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onBack,
    this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeSettingsRoute = 'Profile & Account';
  final UserRepository _userRepository = UserRepositoryImpl();
  String _userNodeId = 'CARREGANDO...';

  @override
  void initState() {
    super.initState();
    _loadUserNodeId();
  }

  void _loadUserNodeId() {
    _userRepository
        .getMyProfile()
        .then((profile) {
          if (mounted) {
            setState(() {
              _userNodeId = profile.nodeId.toUpperCase();
            });
          }
        })
        .catchError((_) {
          if (mounted) {
            setState(() {
              _userNodeId = 'DESCONHECIDO';
            });
          }
        });
  }

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
                    Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: widget.currentTheme.textColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Voltar para o Feed',
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
                'SALA DE CONTROLE',
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
                    'Configurações de Usuário',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: widget.currentTheme.textColor,
                    ),
                  ),
                  Text(
                    'NODE ID • $_userNodeId',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.currentTheme.textColor.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Edite informações importantes do seu perfil.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withValues(alpha: 0.7),
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

                  Expanded(child: _buildSelectedContent()),
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
      case 'Aparência':
        return AppearanceSettingsContent(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
        );
      case 'Privacidade':
        return PrivacySettingsContent(currentTheme: widget.currentTheme);
      case 'Segurança':
        return SecuritySettingsContent(currentTheme: widget.currentTheme);
      case 'Notificações':
        return NotificationsSettingsContent(currentTheme: widget.currentTheme);
      case 'Ajuda':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajuda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Para resolução de bugs ou problemas relacionados ao ecossistema, favor entrar em contato via support@telegrama.zone',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.currentTheme.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      case 'Perfil & Conta':
      default:
        return ProfileSettingsContent(
          currentTheme: widget.currentTheme,
          onProfileUpdated: () {
            _loadUserNodeId();
            widget.onProfileUpdated?.call();
          },
        );
    }
  }
}

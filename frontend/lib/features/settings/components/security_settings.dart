import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class SecuritySettingsContent extends StatefulWidget {
  final AppTheme currentTheme;

  const SecuritySettingsContent({super.key, required this.currentTheme});

  @override
  State<SecuritySettingsContent> createState() => _SecuritySettingsContentState();
}

class _SecuritySettingsContentState extends State<SecuritySettingsContent> {
  final UserRepository _userRepository = UserRepositoryImpl();
  bool _twoFactorAuth = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _userRepository.getPreferences();
      if (mounted) {
        setState(() {
          _twoFactorAuth = prefs.twoFactorAuth;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      await _userRepository.updatePreferences({key: value});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar preferência de segurança: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: widget.currentTheme.primaryColor),
        ),
      );
    }

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
            'Security & Access Keys',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Protect your terminal against unauthorized interception.',
            style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),

          _buildToggleItem(
            title: 'Two-Factor Authentication (2FA)',
            subtitle: 'Require security key verification on new terminal log-ins.',
            value: _twoFactorAuth,
            onChanged: (val) {
              setState(() => _twoFactorAuth = val);
              _savePreference('twoFactorAuth', val);
            },
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            icon: Icons.vpn_key_outlined,
            title: 'Terminal Access Tokens',
            subtitle: 'Manage active CLI keys and authorized web sessions.',
            actionText: 'MANAGE KEYS',
            onTap: () {},
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            icon: Icons.devices_outlined,
            title: 'Active Retro Terminals',
            subtitle: '2 active sessions connected from Berlin and Penedo.',
            actionText: 'REVOKE ALL',
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withOpacity(0.6))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: widget.currentTheme.backgroundColor,
            activeTrackColor: widget.currentTheme.primaryColor,
            inactiveTrackColor: widget.currentTheme.backgroundColor,
            inactiveThumbColor: widget.currentTheme.shadowColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive ? const Color(0xFFFF4D4D).withOpacity(0.15) : widget.currentTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDestructive ? const Color(0xFFFF4D4D) : widget.currentTheme.primaryColor, 
                width: 1.5
              ),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: isDestructive ? const Color(0xFFFF4D4D) : widget.currentTheme.primaryColor
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w900, 
                    color: isDestructive ? const Color(0xFFFF4D4D) : widget.currentTheme.textColor
                  )
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withOpacity(0.6))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.currentTheme.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDestructive ? const Color(0xFFFF4D4D) : widget.currentTheme.shadowColor, 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                ],
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDestructive ? const Color(0xFFFF4D4D) : widget.currentTheme.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

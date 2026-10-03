import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';

class SecuritySettingsContent extends StatefulWidget {
  final AppTheme currentTheme;

  const SecuritySettingsContent({super.key, required this.currentTheme});

  @override
  State<SecuritySettingsContent> createState() => _SecuritySettingsContentState();
}

class _SecuritySettingsContentState extends State<SecuritySettingsContent> {
  bool _twoFactorAuth = true;

  @override
  Widget build(BuildContext context) {
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
            onChanged: (val) => setState(() => _twoFactorAuth = val),
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
          Icon(icon, size: 22, color: widget.currentTheme.textColor.withOpacity(0.7)),
          const SizedBox(width: 14),
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
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.redAccent.withOpacity(0.15) : widget.currentTheme.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDestructive ? Colors.redAccent : widget.currentTheme.shadowColor, width: 1.5),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDestructive ? Colors.redAccent : widget.currentTheme.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
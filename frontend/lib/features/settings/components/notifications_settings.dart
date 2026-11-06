import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class NotificationsSettingsContent extends StatefulWidget {
  final AppTheme currentTheme;

  const NotificationsSettingsContent({super.key, required this.currentTheme});

  @override
  State<NotificationsSettingsContent> createState() => _NotificationsSettingsContentState();
}

class _NotificationsSettingsContentState extends State<NotificationsSettingsContent> {
  final UserRepository _userRepository = UserRepositoryImpl();
  bool _pushNotifications = true;
  bool _soundEchos = true;
  bool _zoneAlerts = false;
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
          _pushNotifications = prefs.pushTransmissions;
          _soundEchos = prefs.acousticEchos;
          _zoneAlerts = prefs.zoneBroadcastAlerts;
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
          SnackBar(content: Text('Erro ao salvar preferência: $e')),
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
            'Transmission Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Customize how your terminal notifies incoming signals and wave echoes.',
            style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),

          _buildToggleItem(
            title: 'Push transmissions',
            subtitle: 'Receive system alerts when new waves hit your radar.',
            value: _pushNotifications,
            onChanged: (val) {
              setState(() => _pushNotifications = val);
              _savePreference('pushTransmissions', val);
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Acoustic echos (Sound)',
            subtitle: 'Play vintage terminal sound feedback on interactions.',
            value: _soundEchos,
            onChanged: (val) {
              setState(() => _soundEchos = val);
              _savePreference('acousticEchos', val);
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Zone broadcast alerts',
            subtitle: 'Notify when high-priority nodes go live inside joined zones.',
            value: _zoneAlerts,
            onChanged: (val) {
              setState(() => _zoneAlerts = val);
              _savePreference('zoneBroadcastAlerts', val);
            },
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
}

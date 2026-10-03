import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class PrivacySettingsContent extends StatefulWidget {
  final AppTheme currentTheme;

  const PrivacySettingsContent({super.key, required this.currentTheme});

  @override
  State<PrivacySettingsContent> createState() => _PrivacySettingsContentState();
}

class _PrivacySettingsContentState extends State<PrivacySettingsContent> {
  bool _privateFrequency = false;
  bool _allowDirectTransmissions = true;
  bool _showNodeActivity = true;

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
            'Privacy & Frequencies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Control who can intercept your transmissions and see your node status.',
            style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),

          _buildToggleItem(
            title: 'Private frequency mode',
            subtitle: 'Only approved nodes can tune into your broadcasted waves.',
            value: _privateFrequency,
            onChanged: (val) => setState(() => _privateFrequency = val),
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Direct transmissions (DMs)',
            subtitle: 'Allow other nodes to send direct private signals to your terminal.',
            value: _allowDirectTransmissions,
            onChanged: (val) => setState(() => _allowDirectTransmissions = val),
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Broadcast node activity',
            subtitle: 'Display your online status and active zones in the retroverse.',
            value: _showNodeActivity,
            onChanged: (val) => setState(() => _showNodeActivity = val),
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
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withOpacity(0.6)),
                ),
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
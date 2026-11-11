import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class PrivacySettingsContent extends StatefulWidget {
  final AppTheme currentTheme;

  const PrivacySettingsContent({super.key, required this.currentTheme});

  @override
  State<PrivacySettingsContent> createState() => _PrivacySettingsContentState();
}

class _PrivacySettingsContentState extends State<PrivacySettingsContent> {
  final UserRepository _userRepository = UserRepositoryImpl();
  bool _privateFrequency = false;
  bool _allowDirectTransmissions = true;
  bool _showNodeActivity = true;
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
          _privateFrequency = prefs.privateFrequencyMode;
          _allowDirectTransmissions = prefs.directTransmissions;
          _showNodeActivity = prefs.broadcastNodeActivity;
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
          child: CircularProgressIndicator(
            color: widget.currentTheme.primaryColor,
          ),
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
            'Configurações de Privacidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: widget.currentTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Controle quem pode interceptar suas transmissões e ver o status do seu terminal.',
            style: TextStyle(
              fontSize: 12.5,
              color: widget.currentTheme.textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          _buildToggleItem(
            title: 'Modo de Posts Privados',
            subtitle: 'Somente seguidores poderão visualizar seus Posts',
            value: _privateFrequency,
            onChanged: (val) {
              setState(() => _privateFrequency = val);
              _savePreference('privateFrequencyMode', val);
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Mensagens Privadas',
            subtitle: 'Ativar mensagens privadas entre nós',
            value: _allowDirectTransmissions,
            onChanged: (val) {
              setState(() => _allowDirectTransmissions = val);
              _savePreference('directTransmissions', val);
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Status de Atividade Público',
            subtitle:
                'Exibir o status de online do seu terminal para outros usuários.',
            value: _showNodeActivity,
            onChanged: (val) {
              setState(() => _showNodeActivity = val);
              _savePreference('broadcastNodeActivity', val);
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: widget.currentTheme.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: widget.currentTheme.textColor.withOpacity(0.6),
                  ),
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

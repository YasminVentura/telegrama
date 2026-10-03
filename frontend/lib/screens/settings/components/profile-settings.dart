import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';

class ProfileSettingsContent extends StatelessWidget {
  final AppTheme currentTheme;

  const ProfileSettingsContent({super.key, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna Esquerda: Public Profile
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                  'Public profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  'What other nodes see across the retroverse.',
                  style: TextStyle(fontSize: 11.5, color: currentTheme.textColor.withOpacity(0.6)),
                ),
                const SizedBox(height: 20),
                
                // Seção de Transmissão de Perfil (Avatar + Botão)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: currentTheme.shadowColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: currentTheme.primaryColor,
                        child: Text('SV', style: TextStyle(fontWeight: FontWeight.bold, color: currentTheme.backgroundColor)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile transmission',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                        ),
                        Text(
                          'JPG or PNG • max 4MB • square signal',
                          style: TextStyle(fontSize: 10.5, color: currentTheme.textColor.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: currentTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, size: 14, color: currentTheme.textColor),
                              const SizedBox(width: 6),
                              Text(
                                'CHANGE IMAGE',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: currentTheme.textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField('DISPLAY NAME', 'Saskia Vance'),
                const SizedBox(height: 16),
                _buildTextField('NODE ID', '@sas_vance', subtitle: 'telegrama.zone/@sas_vance'),
                const SizedBox(height: 16),
                _buildTextField('BIO', 'Exploring high-contrast textures, vintage print design, and modern geometry.', maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField('LOCATION', 'Berlin, Germany'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Coluna Direita: Account Frequency & Save Button
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                      'Account frequency',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Private coordinates used to secure your node.',
                      style: TextStyle(fontSize: 11.5, color: currentTheme.textColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildReadOnlyField('EMAIL', 'saskia@frequency.net', Icons.mail_outline),
                    const SizedBox(height: 12),
                    _buildNavigationItem('Password', 'Last changed 54 days ago', Icons.lock_reset),
                    const SizedBox(height: 12),
                    _buildNavigationItem('Language', 'English (US)', Icons.language),
                    const SizedBox(height: 12),
                    _buildNavigationItem('Time zone', 'Berlin • GMT+2', Icons.access_time),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Sincronização e Botão Salvar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: currentTheme.shadowColor, width: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All changes synced',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: currentTheme.textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 14, color: currentTheme.backgroundColor),
                        const SizedBox(width: 6),
                        Text(
                          'SAVE PROFILE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentTheme.backgroundColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, {String? subtitle, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: currentTheme.textColor.withOpacity(0.6)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: currentTheme.shadowColor, width: 1.5),
          ),
          child: TextField(
            maxLines: maxLines,
            controller: TextEditingController(text: value),
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: currentTheme.textColor),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: currentTheme.textColor.withOpacity(0.4))),
        ],
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: currentTheme.textColor.withOpacity(0.6)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: currentTheme.shadowColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: currentTheme.textColor.withOpacity(0.6)),
              const SizedBox(width: 10),
              Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: currentTheme.textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: currentTheme.textColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: currentTheme.textColor)),
                Text(subtitle, style: TextStyle(fontSize: 10.5, color: currentTheme.textColor.withOpacity(0.5))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: currentTheme.textColor.withOpacity(0.6)),
        ],
      ),
    );
  }
}
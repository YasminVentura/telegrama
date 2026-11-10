import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/models/user_preferences.dart';
import 'package:frontend/shared/components/user_avatar.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class ProfileSettingsContent extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback? onProfileUpdated;

  const ProfileSettingsContent({
    super.key,
    required this.currentTheme,
    this.onProfileUpdated,
  });

  @override
  State<ProfileSettingsContent> createState() => _ProfileSettingsContentState();
}

class _ProfileSettingsContentState extends State<ProfileSettingsContent> {
  String _selectedAvatarUrl = UserPreferences.defaultAvatar;
  String _selectedBannerColor = UserPreferences.defaultBannerColor;
  final UserRepository _userRepository = UserRepositoryImpl();

  late Future<PerfilRespostaDto> _profileFuture;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nodeIdController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _userRepository.getMyProfile();
    _profileFuture.then((profile) {
      if (mounted) {
        final rawAvatar = profile.preferencias?.avatarUrl ??
            profile.avatarUrl ??
            UserRepositoryImpl.selectedAvatarOrDefault;
        final resolvedAvatar =
            UserAvatar.resolvePresetAsset(rawAvatar) ?? rawAvatar;

        final rawBanner = profile.preferencias?.bannerColor ??
            profile.bannerColor ??
            UserRepositoryImpl.selectedBannerColorOrDefault;

        setState(() {
          _nameController.text = profile.nome;
          _nodeIdController.text = profile.nodeId.startsWith('@')
              ? profile.nodeId
              : '@${profile.nodeId}';
          _bioController.text = profile.bio ?? '';
          _locationController.text = profile.localizacao ?? '';
          _userEmail = profile.email;
          _selectedAvatarUrl = resolvedAvatar;
          _selectedBannerColor = rawBanner;
        });
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nodeIdController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Seleciona uma das 6 fotos fixas no preview; a alteração é efetivada ao clicar em "SAVE PROFILE"
  void _selectFixedAvatar(String avatarAssetPath) {
    final resolved =
        UserAvatar.resolvePresetAsset(avatarAssetPath) ?? avatarAssetPath;
    setState(() {
      _selectedAvatarUrl = resolved;
    });
  }

  /// Seleciona uma das cores fixas da capa no preview; efetivada ao clicar em "SAVE PROFILE"
  void _selectBannerColor(String hexColor) {
    setState(() {
      _selectedBannerColor = hexColor;
    });
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final resolvedAvatar =
          UserAvatar.resolvePresetAsset(_selectedAvatarUrl) ??
              _selectedAvatarUrl;
      UserRepositoryImpl.setExplicitAvatarChoice(resolvedAvatar);
      UserRepositoryImpl.setExplicitBannerColorChoice(_selectedBannerColor);

      final updateData = {
        'nome': _nameController.text,
        'bio': _bioController.text,
        'localizacao': _locationController.text,
        'avatarUrl': resolvedAvatar,
        'bannerColor': _selectedBannerColor,
        'preferencias': {
          'avatarUrl': resolvedAvatar,
          'bannerColor': _selectedBannerColor,
        },
      };

      await _userRepository.updatePreferences({
        'avatarUrl': resolvedAvatar,
        'bannerColor': _selectedBannerColor,
      });
      await _userRepository.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );

        widget.onProfileUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilRespostaDto>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erro ao carregar configurações: ${snapshot.error}',
                  style: TextStyle(color: widget.currentTheme.textColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _loadProfile()),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna Esquerda: Public Profile
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
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
                      'Public profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'What other nodes see across the retroverse.',
                      style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 16),

                    // Preview do fundo da capa atrás do avatar
                    Container(
                      height: 95,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: UserPreferences.parseBannerColor(
                          _selectedBannerColor,
                          fallback: widget.currentTheme.secondaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: widget.currentTheme.backgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                        ),
                        child: UserAvatar(
                          name: _nameController.text.isNotEmpty ? _nameController.text : 'User',
                          radius: 28,
                          imageUrl: _selectedAvatarUrl,
                          borderColor: widget.currentTheme.shadowColor,
                          showShadow: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'COR DE FUNDO DA CAPA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: widget.currentTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: UserPreferences.fixedBannerColors.map((hexColor) {
                        final bool isSelected =
                            _selectedBannerColor.toUpperCase() == hexColor.toUpperCase();
                        final Color swatchColor = UserPreferences.parseBannerColor(hexColor);
                        return GestureDetector(
                          onTap: () => _selectBannerColor(hexColor),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: swatchColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? widget.currentTheme.primaryColor
                                      : widget.currentTheme.shadowColor,
                                  width: isSelected ? 3 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: widget.currentTheme.shadowColor,
                                          offset: const Offset(2, 2),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'FOTO DO PERFIL (6 IMAGENS FIXAS)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: widget.currentTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grade com as 6 fotos de perfil fixas
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.currentTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                      ),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.spaceEvenly,
                        children: UserPreferences.fixedAvatars.map((avatarPath) {
                          final bool isSelected =
                              (UserAvatar.resolvePresetAsset(_selectedAvatarUrl) ?? _selectedAvatarUrl) == avatarPath;

                          return GestureDetector(
                            onTap: () => _selectFixedAvatar(avatarPath),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? widget.currentTheme.primaryColor
                                          : widget.currentTheme.backgroundColor,
                                      border: Border.all(
                                        color: isSelected
                                            ? widget.currentTheme.primaryColor
                                            : widget.currentTheme.shadowColor,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: widget.currentTheme.shadowColor,
                                                offset: const Offset(2, 2),
                                                blurRadius: 0,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: UserAvatar(
                                      imageUrl: avatarPath,
                                      name: _nameController.text.isNotEmpty ? _nameController.text : 'User',
                                      radius: 26,
                                      showShadow: false,
                                      borderWidth: 1.5,
                                      borderColor: widget.currentTheme.shadowColor,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: widget.currentTheme.primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 11,
                                          color: widget.currentTheme.backgroundColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField('DISPLAY NAME', _nameController),
                    const SizedBox(height: 16),
                    _buildTextField('NODE ID', _nodeIdController, subtitle: 'telegrama.zone/${_nodeIdController.text}', readOnly: true),
                    const SizedBox(height: 16),
                    _buildTextField('BIO', _bioController, maxLines: 2, hintText: 'Exploring high-contrast textures...'),
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
                          'Account frequency',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Private coordinates used to secure your node.',
                          style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 20),

                        _buildReadOnlyField('EMAIL', _userEmail.isNotEmpty ? _userEmail : 'N/A', Icons.mail_outline),
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
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All changes synced',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _isSaving ? null : _saveProfile,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.currentTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                              boxShadow: [
                                BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (_isSaving)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: widget.currentTheme.backgroundColor,
                                    ),
                                  )
                                else ...[
                                  Icon(Icons.check, size: 14, color: widget.currentTheme.backgroundColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'SAVE PROFILE',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.currentTheme.backgroundColor),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? subtitle,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: readOnly ? widget.currentTheme.backgroundColor.withValues(alpha: 0.5) : widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
          ),
          child: TextField(
            readOnly: readOnly,
            maxLines: maxLines,
            controller: controller,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 12, color: widget.currentTheme.textColor.withValues(alpha: 0.4)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: widget.currentTheme.textColor.withValues(alpha: 0.4))),
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
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor)),
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
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: widget.currentTheme.textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor)),
                Text(subtitle, style: TextStyle(fontSize: 10.5, color: widget.currentTheme.textColor.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}

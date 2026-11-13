import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/models/user_preferences.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';

class RegisterScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback onRegisterSuccess;
  final VoidCallback onNavigateToLogin;
  final VoidCallback? onContinueAsGuest;

  const RegisterScreen({
    super.key,
    required this.currentTheme,
    required this.onRegisterSuccess,
    required this.onNavigateToLogin,
    this.onContinueAsGuest,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nodeIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedAvatarUrl;
  bool _acceptTerms = true;
  bool _isHoveredButton = false;
  bool _isLoading = false;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void dispose() {
    _displayNameController.dispose();
    _nodeIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_displayNameController.text.isEmpty ||
        _nodeIdController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    if (_selectedAvatarUrl == null || _selectedAvatarUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escolha uma foto de perfil para o seu nó.'),
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você deve aceitar os termos de uso.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.registro(
        _displayNameController.text.trim(),
        _nodeIdController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _acceptTerms,
        avatarUrl: _selectedAvatarUrl,
      );

      widget.onRegisterSuccess();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha no cadastro: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentTheme.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(flex: 5, child: _buildLeftHeroPanel(context)),
                Expanded(flex: 5, child: _buildRightFormPanel(context)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 520, child: _buildLeftHeroPanel(context)),
                  _buildRightFormPanel(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftHeroPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: widget.currentTheme.secondaryColor,
        border: Border(
          right: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
        ),
        image: const DecorationImage(
          image: AssetImage('lib/assets/images/signal_artwork.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.currentTheme.primaryColor,
                  border: Border.all(
                    color: widget.currentTheme.shadowColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.waves,
                  color: widget.currentTheme.backgroundColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Telegrama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 200),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.currentTheme.shadowColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'NOVA TRANSMISSÃO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: widget.currentTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reivindique seu canto\ndo retroverso.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Transmita ideias, descubra frequências estranhas e encontre os nós que tornam seu sinal mais forte.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightFormPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      color: widget.currentTheme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'REGISTRO DE NÓ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Crie sua frequência',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Algumas coordenadas e seu nó do Telegrama estará pronto para transmitir.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel('ESCOLHA O AVATAR DO SEU NÓ'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: UserPreferences.fixedAvatars.map((preset) {
                  final bool isSelected = _selectedAvatarUrl == preset;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarUrl = preset),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
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
                                width: isSelected ? 2.5 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.currentTheme.shadowColor,
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: UserAvatar(
                              imageUrl: preset,
                              name: _displayNameController.text.isNotEmpty
                                  ? _displayNameController.text
                                  : 'Node',
                              radius: 22,
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
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: widget.currentTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.currentTheme.shadowColor,
                                    width: 1.5,
                                  ),
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
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('NOME DE EXIBIÇÃO'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _displayNameController,
                          style: TextStyle(
                            color: widget.currentTheme.textColor,
                            fontSize: 13.5,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Saskia Vance',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('ID DE NÓ'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nodeIdController,
                          style: TextStyle(
                            color: widget.currentTheme.textColor,
                            fontSize: 13.5,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'sas_vance',
                            prefixIcon: Icons.alternate_email,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('EMAIL'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                style: TextStyle(
                  color: widget.currentTheme.textColor,
                  fontSize: 13.5,
                ),
                decoration: _inputDecoration(
                  hintText: 'saskia@frequency.net',
                  prefixIcon: Icons.mail_outline,
                ),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('SENHA'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                  color: widget.currentTheme.textColor,
                  fontSize: 13.5,
                ),
                decoration: _inputDecoration(
                  hintText: 'Insira +8 caracteres',
                  prefixIcon: Icons.lock_outline,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Signal strength: waiting for input',
                style: TextStyle(
                  fontSize: 11.5,
                  color: widget.currentTheme.textColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _acceptTerms,
                      activeColor: widget.currentTheme.primaryColor,
                      checkColor: widget.currentTheme.backgroundColor,
                      side: BorderSide(
                        color: widget.currentTheme.shadowColor,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) =>
                          setState(() => _acceptTerms = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Eu aceito os Termos de Uso',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: widget.currentTheme.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredButton = true),
                onExit: (_) => setState(() => _isHoveredButton = false),
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleRegister,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.currentTheme.shadowColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentTheme.shadowColor,
                          offset: _isHoveredButton
                              ? const Offset(1, 1)
                              : const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: widget.currentTheme.backgroundColor,
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          Icon(
                            Icons.wifi,
                            color: widget.currentTheme.backgroundColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CRIE MEU NÓ',
                            style: TextStyle(
                              color: widget.currentTheme.backgroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Já tem uma conta criada?',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: widget.currentTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: widget.onNavigateToLogin,
                      child: Text(
                        'Entre no seu nó',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (widget.onContinueAsGuest != null) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: widget.onContinueAsGuest,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Voltar para o Feed público (sem login)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.textColor.withOpacity(
                                0.65,
                              ),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: widget.currentTheme.textColor,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        color: widget.currentTheme.textColor.withOpacity(0.4),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: widget.currentTheme.textColor,
        size: 18,
      ),
      filled: true,
      fillColor: widget.currentTheme.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.currentTheme.shadowColor,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.currentTheme.primaryColor,
          width: 2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class RegisterScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback onRegisterSuccess;
  final VoidCallback onNavigateToLogin;

  const RegisterScreen({
    super.key,
    required this.currentTheme,
    required this.onRegisterSuccess,
    required this.onNavigateToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nodeIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _acceptTerms = true;
  bool _isHoveredButton = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _nodeIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(Icons.waves, color: widget.currentTheme.backgroundColor, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'NEW TRANSMISSION',
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
                'Claim your corner\nof the retroverse.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Broadcast ideas, discover strange frequencies and find the nodes that make your signal stronger.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ],
          ),

          // Rodapé: Widget de Frequência de Rádio[cite: 4]
        ],
      ),
    );
  }

  // Lado Direito: Formulário de Registro
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
                'NODE REGISTRATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your frequency',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A few coordinates and your Telegrama node will be ready to transmit.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Linha dupla: Display Name e Node ID[cite: 4]
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('DISPLAY NAME'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _displayNameController,
                          style: TextStyle(color: widget.currentTheme.textColor, fontSize: 13.5),
                          decoration: _inputDecoration(hintText: 'Saskia Vance', prefixIcon: Icons.person_outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('NODE ID'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nodeIdController,
                          style: TextStyle(color: widget.currentTheme.textColor, fontSize: 13.5),
                          decoration: _inputDecoration(hintText: '@sas_vance', prefixIcon: Icons.alternate_email),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo Email[cite: 4]
              _buildFieldLabel('EMAIL'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                style: TextStyle(color: widget.currentTheme.textColor, fontSize: 13.5),
                decoration: _inputDecoration(hintText: 'saskia@frequency.net', prefixIcon: Icons.mail_outline),
              ),
              const SizedBox(height: 16),

              // Campo Password[cite: 4]
              _buildFieldLabel('PASSWORD'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: widget.currentTheme.textColor, fontSize: 13.5),
                decoration: _inputDecoration(hintText: 'Choose 8+ characters', prefixIcon: Icons.lock_outline),
              ),
              const SizedBox(height: 6),
              Text(
                'Signal strength: waiting for input',
                style: TextStyle(fontSize: 11.5, color: widget.currentTheme.textColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),

              // Checkbox de Termos[cite: 4]
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _acceptTerms,
                      activeColor: widget.currentTheme.primaryColor,
                      checkColor: widget.currentTheme.backgroundColor,
                      side: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) => setState(() => _acceptTerms = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'I accept the Terms of Waves and Privacy Frequency.',
                    style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botão Principal: CREATE MY NODE[cite: 4]
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredButton = true),
                onExit: (_) => setState(() => _isHoveredButton = false),
                child: GestureDetector(
                  onTap: widget.onRegisterSuccess,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentTheme.shadowColor,
                          offset: _isHoveredButton ? const Offset(1, 1) : const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi, color: widget.currentTheme.backgroundColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'CREATE MY NODE',
                          style: TextStyle(
                            color: widget.currentTheme.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Rodapé: Já possui conta / Sign in[cite: 4]
              Center(
                child: Column(
                  children: [
                    Text(
                      'Already broadcasting?',
                      style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: widget.onNavigateToLogin,
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nota de rodapé da rede[cite: 4]
              Center(
                child: Text(
                  'BY JOINING YOU AGREE TO THE COMMUNITY FREQUENCY CODE',
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 0.8,
                    color: widget.currentTheme.textColor.withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

  InputDecoration _inputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: widget.currentTheme.textColor.withOpacity(0.4)),
      prefixIcon: Icon(prefixIcon, color: widget.currentTheme.textColor, size: 18),
      filled: true,
      fillColor: widget.currentTheme.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.currentTheme.primaryColor, width: 2),
      ),
    );
  }
}
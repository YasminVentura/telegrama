import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onNavigateToForgotPassword;
  final VoidCallback? onContinueAsGuest;

  const LoginScreen({
    super.key,
    required this.currentTheme,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
    required this.onNavigateToForgotPassword,
    this.onContinueAsGuest,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isHoveredButton = false;
  bool _isLoading = false;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.login(_emailController.text, _passwordController.text);
      widget.onLoginSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login: $e')),
      );
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
                  SizedBox(height: 500, child: _buildLeftHeroPanel(context)),
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
          image: AssetImage('lib/assets/images/signal_artwork.png'), // Substitua pelo caminho do seu asset/imagem
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
                  'RETURN TRANSMISSION',
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
                'Tune back into\nyour frequencies.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your zones, waves and saved reels are waiting on the other side of the signal..',
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
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      color: widget.currentTheme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NODE ACCESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, traveler',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your credentials to reconnect with the retroverse.',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 36),

              _buildFieldLabel('EMAIL OR NODE ID'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
                decoration: _inputDecoration(
                  hintText: 'you@frequency.net',
                  prefixIcon: Icons.alternate_email,
                ),
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('PASSWORD'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
                decoration: _inputDecoration(
                  hintText: '••••••••••••',
                  prefixIcon: Icons.lock_outline,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: widget.currentTheme.primaryColor,
                          checkColor: widget.currentTheme.backgroundColor,
                          side: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Keep this node connected',
                        style: TextStyle(fontSize: 13, color: widget.currentTheme.textColor),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {widget.onNavigateToForgotPassword();},
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredButton = true),
                onExit: (_) => setState(() => _isHoveredButton = false),
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
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
                          Icon(Icons.wifi, color: widget.currentTheme.backgroundColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ENTER THE RETROVERSE',
                            style: TextStyle(
                              color: widget.currentTheme.backgroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Text(
                      'New frequency?',
                      style: TextStyle(fontSize: 13, color: widget.currentTheme.textColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: widget.onNavigateToRegister,
                      child: Text(
                        'Create your Telegrama node',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (widget.onContinueAsGuest != null) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: widget.onContinueAsGuest,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Voltar para o Feed público (sem login)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.textColor.withOpacity(0.65),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: widget.currentTheme.textColor,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: widget.currentTheme.textColor.withOpacity(0.4)),
      prefixIcon: Icon(prefixIcon, color: widget.currentTheme.textColor, size: 20),
      filled: true,
      fillColor: widget.currentTheme.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
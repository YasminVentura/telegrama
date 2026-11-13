import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class WelcomeScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback onNavigateToLogin;
  final VoidCallback onNavigateToRegister;
  final VoidCallback? onContinueAsGuest;

  const WelcomeScreen({
    super.key,
    required this.currentTheme,
    required this.onNavigateToLogin,
    required this.onNavigateToRegister,
    this.onContinueAsGuest,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isHoveredLogin = false;
  bool _isHoveredRegister = false;

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
                Expanded(flex: 5, child: _buildRightActionPanel(context)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 500, child: _buildLeftHeroPanel(context)),
                  _buildRightActionPanel(context),
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
            mainAxisSize: MainAxisSize.min,
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
                  'SIGNAL TRANSMISSION',
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
                'Connect across\nthe retroverse.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your frequency, broadcast your ideas and find your nodes.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRightActionPanel(BuildContext context) {
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
                'WELCOME TRAVELER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to transmit?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Access your existing node or initialize a brand new frequency.',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredLogin = true),
                onExit: (_) => setState(() => _isHoveredLogin = false),
                child: GestureDetector(
                  onTap: widget.onNavigateToLogin,
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
                          offset: _isHoveredLogin ? const Offset(1, 1) : const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: widget.currentTheme.backgroundColor, size: 18),
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredRegister = true),
                onExit: (_) => setState(() => _isHoveredRegister = false),
                child: GestureDetector(
                  onTap: widget.onNavigateToRegister,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentTheme.shadowColor,
                          offset: _isHoveredRegister ? const Offset(1, 1) : const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined, color: widget.currentTheme.textColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'CREATE YOUR NODE',
                          style: TextStyle(
                            color: widget.currentTheme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.onContinueAsGuest != null)
                Center(
                  child: GestureDetector(
                    onTap: widget.onContinueAsGuest,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        'Continuar sem login (acessar apenas o Feed)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.textColor.withOpacity(0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

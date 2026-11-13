import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final VoidCallback onNavigateToLogin;

  const ForgotPasswordScreen({
    super.key,
    required this.currentTheme,
    required this.onNavigateToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isHoveredSend = false;
  bool _isHoveredReturn = false;

  @override
  void dispose() {
    _emailController.dispose();
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
                Expanded(flex: 5, child: _buildRightActionPanel(context)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 520, child: _buildLeftHeroPanel(context)),
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
                  'SIGNAL RECOVERY',
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
                "Lost the\nfrequency? We'll\nfind it.",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Send a recovery pulse to your email and reconnect to every zone, reel and conversation.',
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
                'RECOVERY CHANNEL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reset your password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter the email linked to your node. We'll transmit a secure reset link that expires in 20 minutes.",
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure pulse protocol',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For your safety, we never send passwords. The link only lets you create a fresh access key.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: widget.currentTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'RECOVERY EMAIL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'you@frequency.net',
                  hintStyle: TextStyle(fontSize: 14, color: widget.currentTheme.textColor.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.alternate_email, color: widget.currentTheme.textColor, size: 20),
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
                ),
              ),
              const SizedBox(height: 24),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredSend = true),
                onExit: (_) => setState(() => _isHoveredSend = false),
                child: GestureDetector(
                  onTap: () {

                  },
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
                          offset: _isHoveredSend ? const Offset(1, 1) : const Offset(4, 4),
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
                          'SEND RECOVERY PULSE',
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
              const SizedBox(height: 16),

              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredReturn = true),
                onExit: (_) => setState(() => _isHoveredReturn = false),
                child: GestureDetector(
                  onTap: widget.onNavigateToLogin,
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
                          offset: _isHoveredReturn ? const Offset(1, 1) : const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, color: widget.currentTheme.textColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'RETURN TO LOGIN',
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
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'NEED HELP? CONTACT SIGNAL SUPPORT • CHANNEL 404',
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
}

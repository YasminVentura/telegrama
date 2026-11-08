import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/forget_password_screen.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:frontend/features/auth/sign_up_screen.dart';
import 'package:frontend/features/auth/welcome_screen.dart';
import 'package:frontend/features/feed/main_feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppTheme _currentTheme = AppTheme.retroGreen;
  final AuthRepository _authRepository = AuthRepository();

  bool _isCheckingSession = true;
  String _currentRoute = 'feed';

  @override
  void initState() {
    super.initState();
    _verificarSessaoInicial();
  }

  Future<void> _verificarSessaoInicial() async {
    final sessaoValida = await _authRepository.restaurarSessao();
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
        // Se a sessão ainda estiver válida (ou renovada via refreshToken), entra direto no feed logado.
        // Caso não esteja logado, ainda pode acessar o feed em modo visitante.
        _currentRoute = sessaoValida ? 'feed' : 'feed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegrama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _isCheckingSession
          ? Scaffold(
              backgroundColor: _currentTheme.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: _currentTheme.primaryColor,
                ),
              ),
            )
          : _getScreen(),
    );
  }

  Widget _getScreen() {
    switch (_currentRoute) {
      case 'welcome':
        return WelcomeScreen(
          currentTheme: _currentTheme,
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
          onNavigateToRegister: () => setState(() => _currentRoute = 'register'),
          onContinueAsGuest: () => setState(() => _currentRoute = 'feed'),
        );

      case 'login':
        return LoginScreen(
          currentTheme: _currentTheme,
          onLoginSuccess: () {
            setState(() => _currentRoute = 'feed');
          },
          onNavigateToRegister: () => setState(() => _currentRoute = 'register'),
          onNavigateToForgotPassword: () =>
              setState(() => _currentRoute = 'forget-password'),
          onContinueAsGuest: () => setState(() => _currentRoute = 'feed'),
        );

      case 'register':
        return RegisterScreen(
          currentTheme: _currentTheme,
          onRegisterSuccess: () {
            setState(() => _currentRoute = 'feed');
          },
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
          onContinueAsGuest: () => setState(() => _currentRoute = 'feed'),
        );

      case 'forget-password':
        return ForgotPasswordScreen(
          currentTheme: _currentTheme,
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
        );

      case 'feed':
      default:
        return MainFeedScreen(
          onRequireLogin: () => setState(() => _currentRoute = 'login'),
          onNavigateToRegister: () => setState(() => _currentRoute = 'register'),
          onLogout: () async {
            await _authRepository.logout();
            if (mounted) {
              setState(() => _currentRoute = 'login');
            }
          },
        );
    }
  }
}

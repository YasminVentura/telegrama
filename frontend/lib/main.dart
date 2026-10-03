import 'package:flutter/material.dart';
import 'package:frontend/features/feed/main_feed_screen.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:frontend/features/auth/sign_up_screen.dart'; // Ajuste para register_screen.dart se for o caso
import 'package:frontend/features/auth/welcome_screen.dart';
import 'package:frontend/features/auth/forget_password_screen.dart';
import 'package:frontend/core/themes/app_themes.dart';

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

  String _currentRoute = 'welcome';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegrama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _getScreen(),
    );
  }

  Widget _getScreen() {
    switch (_currentRoute) {
      case 'welcome':
        return WelcomeScreen(
          currentTheme: _currentTheme,
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
          onNavigateToRegister: () => setState(() => _currentRoute = 'register'),
        );

      case 'login':
        return LoginScreen(
          currentTheme: _currentTheme,
          onLoginSuccess: () {
            setState(() => _currentRoute = 'feed');
          },
          onNavigateToRegister: () => setState(() => _currentRoute = 'register'),
          onNavigateToForgotPassword: () => setState(() => _currentRoute = 'forget-password'),
        );

      case 'register':
        return RegisterScreen(
          currentTheme: _currentTheme,
          onRegisterSuccess: () {
            setState(() => _currentRoute = 'feed');
          },
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
        );

      case 'forget-password':
        return ForgotPasswordScreen(
          currentTheme: _currentTheme,
          onNavigateToLogin: () => setState(() => _currentRoute = 'login'),
        );

      case 'feed':
      default:
        return const MainFeedScreen();
    }
  }
}
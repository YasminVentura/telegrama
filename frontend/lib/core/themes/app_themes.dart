import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color shadowColor;
  final Color textColor;

  const AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.shadowColor,
    required this.textColor,
  });

  static const AppTheme retroGreen = AppTheme(
    name: 'Retro Green',
    backgroundColor: Color(0xFFF2F8F5),
    primaryColor: Color(0xFFFF6B4A),
    secondaryColor: Color(0xFF45B69C),
    shadowColor: Color(0xFF000000),
    textColor: Color(0xFF000000),
  );

  static const AppTheme cyberpunk = AppTheme(
    name: 'Cyberpunk Dark',
    backgroundColor: Color(0xFF121214),
    primaryColor: Color(0xFFFF007F),
    secondaryColor: Color(0xFF00F0FF),
    shadowColor: Color(0xFF00F0FF),
    textColor: Color(0xFFFFFFFF),
  );

  static const AppTheme synthwave = AppTheme(
    name: 'Sunset Synthwave',
    backgroundColor: Color(0xFF2B1B4E),
    primaryColor: Color(0xFFFF71CE),
    secondaryColor: Color(0xFF01CDFE),
    shadowColor: Color(0xFFB967FF),
    textColor: Color(0xFFFFFDF9),
  );

  static const AppTheme hacker = AppTheme(
    name: 'Monokai Hacker',
    backgroundColor: Color(0xFF1E1E1E),
    primaryColor: Color(0xFFA6E22E),
    secondaryColor: Color(0xFF66D9EF),
    shadowColor: Color(0xFFA6E22E),
    textColor: Color(0xFFF8F8F2),
  );

  static const AppTheme espresso = AppTheme(
    name: 'Cream & Espresso',
    backgroundColor: Color(0xFFF7F3EE),
    primaryColor: Color(0xFFD35400),
    secondaryColor: Color(0xFF7D6B5D),
    shadowColor: Color(0xFF2C221E),
    textColor: Color(0xFF2C221E),
  );
}
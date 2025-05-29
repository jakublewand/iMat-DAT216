import 'package:flutter/material.dart';

class AppTheme {
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMediumSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingHuge = 32.0;

  // Color definitions
  static const Color accentColor = Color(0xFFEA8B32);
  static const Color secondaryColor = Color(0xFF745944);
  static const Color backgroundColor = Colors.white;
  static const Color primaryColor = Color(0xFFF3DFD2);
  static const Color primaryShadowColor = Color(0xFFE3C0A6);

  // Theme color scheme
  static ColorScheme colorScheme = ColorScheme.light(
    primary: primaryColor,
    primaryContainer: primaryShadowColor,
    secondary: secondaryColor,
    surface: backgroundColor,
    onPrimary: Colors.black87,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    outline: Color(0xFF847469),
  );
}

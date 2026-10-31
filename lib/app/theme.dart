import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF9500),
        surface: Color(0xFFFFFFFF),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF101014),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF9500),
        surface: Color(0xFF1C1C24),
      ),
    );
  }
}
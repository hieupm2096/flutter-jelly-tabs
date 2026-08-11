import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _background = Color(0xFF11100F);

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF59E0B),
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
    );
  }
}

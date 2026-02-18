import 'package:flutter/material.dart';

class AppTheme {
  // Primary palette - Vibrant teal/cyan for productivity
  static const _primaryLight = Color(0xFF00BFA6); // Teal accent
  static const _primaryDark = Color(0xFF64FFDA); // Brighter teal for dark mode

  // Secondary - Warm coral for actions/highlights
  static const _secondaryLight = Color(0xFFFF7043);
  static const _secondaryDark = Color(0xFFFFAB91);

  // Tertiary - Purple for accents
  static const _tertiaryLight = Color(0xFF7C4DFF);
  static const _tertiaryDark = Color(0xFFB388FF);

  // Error color
  static const _error = Color(0xFFEF5350);

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFB2DFDB),
      onPrimaryContainer: Color(0xFF00695C),

      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFCCBC),
      onSecondaryContainer: Color(0xFFBF360C),

      tertiary: _tertiaryLight,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD1C4E9),
      onTertiaryContainer: Color(0xFF311B92),

      surface: Colors.white,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: Color(0xFFF0F0F5),
      surfaceContainerHigh: Color(0xFFF5F5FA),

      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),

      error: _error,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFFF8F9FC),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1A2E),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: Color(0xFF003730),
      primaryContainer: Color(0xFF004D40),
      onPrimaryContainer: Color(0xFF64FFDA),

      secondary: _secondaryDark,
      onSecondary: Color(0xFF5D1F0F),
      secondaryContainer: Color(0xFFBF360C),
      onSecondaryContainer: Color(0xFFFFCCBC),

      tertiary: _tertiaryDark,
      onTertiary: Color(0xFF21005D),
      tertiaryContainer: Color(0xFF4A148C),
      onTertiaryContainer: Color(0xFFEADDFF),

      surface: Color(0xFF121218),
      onSurface: Color(0xFFE8E8EE),
      surfaceContainerHighest: Color(0xFF2A2A35),
      surfaceContainerHigh: Color(0xFF1E1E28),

      outline: Color(0xFF5C5C6E),
      outlineVariant: Color(0xFF3A3A48),

      error: _error,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFF0D0D12),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE8E8EE),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: Color(0xFF003730),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E28),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF003730),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

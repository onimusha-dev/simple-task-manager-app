import 'package:flutter/material.dart';

class AppThemePreset {
  final String name;
  final Color seedColor;
  final bool useDynamic;

  const AppThemePreset({
    required this.name,
    required this.seedColor,
    this.useDynamic = false,
  });
}

class AppThemes {
  static const catppuccin = AppThemePreset(
    name: 'Catppuccin',
    seedColor: Colors.deepPurple,
  );

  static const dynamic = AppThemePreset(
    name: 'Dynamic',
    seedColor: Colors.blue, // fallback only
    useDynamic: true,
  );

  static const miku = AppThemePreset(
    name: 'Miku',
    seedColor: Color(0xFF00BFA6),
  );

  static const asuka = AppThemePreset(
    name: 'Asuka',
    seedColor: Color(0xFFFF5A36),
  );

  static const rikka = AppThemePreset(
    name: 'Rikka',
    seedColor: Color(0xFF3D5AFE),
  );

  static const presets = [catppuccin, dynamic, miku, asuka, rikka];
}

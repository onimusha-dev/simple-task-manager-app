import 'package:flutter/material.dart';

class AppThemePreset {
  final String name;
  final Color seedColor;

  const AppThemePreset({required this.name, required this.seedColor});
}

class AppThemes {
  static const catppuccin = AppThemePreset(
    name: 'Catppuccin',
    seedColor: Colors.deepPurple,
  );

  static const tatsumaki = AppThemePreset(
    name: 'Tatsumaki',
    seedColor: Color(0xFF00BFA6),
  );

  static const rose = AppThemePreset(
    name: 'Rose',
    seedColor: Colors.pinkAccent,
  );

  // 🎤 Hatsune Miku — canonical teal
  static const miku = AppThemePreset(
    name: 'Miku',
    seedColor: Color(0xFF86CECB),
  );

  // 🔥 Asuka Langley — warm aggressive red
  static const asuka = AppThemePreset(
    name: 'Asuka',
    seedColor: Color(0xFFFF5A36),
  );

  // ⚡ Rikka Takanashi — chuunibyou blue
  static const rikka = AppThemePreset(
    name: 'Rikka',
    seedColor: Color(0xFF3D5AFE),
  );

  // 🌸 Sakura — blossom pink
  static const sakura = AppThemePreset(
    name: 'Sakura',
    seedColor: Color(0xFFFF92A8),
  );

  static const presets = [
    catppuccin,
    tatsumaki,
    rose,
    miku,
    asuka,
    rikka,
    sakura,
  ];
}

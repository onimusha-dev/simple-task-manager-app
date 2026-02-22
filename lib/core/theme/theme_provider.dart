import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/AppThemes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Mode Controller
final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  () => ThemeController(),
);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    state = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString('theme', value);
  }
}

// Theme Preset Provider
final themePresetProvider =
    NotifierProvider<ThemePresetController, AppThemePreset>(
      () => ThemePresetController(),
    );

class ThemePresetController extends Notifier<AppThemePreset> {
  @override
  AppThemePreset build() {
    _load();
    return AppThemes.catppuccin;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_preset');

    if (saved != null) {
      final preset = AppThemes.presets.firstWhere(
        (p) => p.name == saved,
        orElse: () => AppThemes.catppuccin,
      );
      state = preset;
    }
  }

  Future<void> setPreset(AppThemePreset preset) async {
    state = preset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_preset', preset.name);
  }
}

// Dynamic Theme Providers
final lightThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(themePresetProvider);
  return _buildTheme(preset.seedColor, Brightness.light);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(themePresetProvider);
  return _buildTheme(preset.seedColor, Brightness.dark);
});

ThemeData _buildTheme(Color seedColor, Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF8F9FC)
        : const Color(0xFF0D0D12),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: brightness == Brightness.light
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFE8E8EE),
    ),
    cardTheme: CardThemeData(
      elevation: brightness == Brightness.light ? 2 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF1E1E28),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

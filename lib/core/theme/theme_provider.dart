import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// Pure Dark Provider
final pureDarkProvider = NotifierProvider<PureDarkController, bool>(
  () => PureDarkController(),
);

class PureDarkController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('pure_dark') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pure_dark', state);
  }
}

// Double Tap To Exit Provider
final doubleTapToExitProvider =
    NotifierProvider<DoubleTapToExitController, bool>(
      () => DoubleTapToExitController(),
    );

class DoubleTapToExitController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('double_tap_to_exit') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('double_tap_to_exit', state);
  }
}

// Dynamic Theme Providers

final lightThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(themePresetProvider);
  return buildTheme(
    ColorScheme.fromSeed(seedColor: preset.seedColor),
    Brightness.light,
    false, // light theme never uses pure dark
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(themePresetProvider);
  final pureDark = ref.watch(pureDarkProvider);
  return buildTheme(
    ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Brightness.dark,
    ),
    Brightness.dark,
    pureDark,
  );
});

ThemeData buildTheme(
  ColorScheme colorScheme,
  Brightness brightness,
  bool pureDark,
) {
  final isDark = brightness == Brightness.dark;

  // 🎨 Calculate Background Color (Subtle tint of primary)
  // For light: very faint tint
  // For dark: deep dark tint, unless pureDark is true
  Color backgroundColor;
  if (isDark) {
    backgroundColor = pureDark
        ? Colors.black
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.05),
            const Color(0xFF0D0D12),
          );
  } else {
    backgroundColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.03),
      const Color(0xFFF8F9FC),
    );
  }

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark
          ? const Color(0xFFE8E8EE)
          : const Color(0xFF1A1A2E),
    ),
    cardTheme: CardThemeData(
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark
          ? (pureDark ? const Color(0xFF121212) : const Color(0xFF1E1E28))
          : Colors.white,
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

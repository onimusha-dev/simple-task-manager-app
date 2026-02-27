import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/app_themes.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';

// Theme State
class ThemeState {
  final ThemeMode themeMode;
  final AppThemePreset preset;
  final bool pureDark;

  const ThemeState({
    required this.themeMode,
    required this.preset,
    required this.pureDark,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppThemePreset? preset,
    bool? pureDark,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      preset: preset ?? this.preset,
      pureDark: pureDark ?? this.pureDark,
    );
  }
}

// Theme Provider
final themeProvider = NotifierProvider<ThemeController, ThemeState>(
  () => ThemeController(),
);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return _loadState();
  }

  ThemeState _loadState() {
    final themeStr = AppPreferences.getPreference(AppPreferences.keyTheme);
    final presetStr = AppPreferences.getPreference(
      AppPreferences.keyThemePreset,
    );
    final pureDark =
        AppPreferences.getPreferenceBool(AppPreferences.keyPureDark) ?? false;

    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final preset = AppThemes.presets.firstWhere(
      (p) => p.name == presetStr,
      orElse: () => AppThemes.catppuccin,
    );

    return ThemeState(themeMode: themeMode, preset: preset, pureDark: pureDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await AppPreferences.setPreference(AppPreferences.keyTheme, value);
  }

  Future<void> setPreset(AppThemePreset preset) async {
    state = state.copyWith(preset: preset);
    await AppPreferences.setPreference(
      AppPreferences.keyThemePreset,
      preset.name,
    );
  }

  Future<void> togglePureDark() async {
    final pureDark = !state.pureDark;
    state = state.copyWith(pureDark: pureDark);
    await AppPreferences.setPreferenceBool(
      AppPreferences.keyPureDark,
      pureDark,
    );
  }
}

ThemeData buildTheme(
  ColorScheme colorScheme,
  Brightness brightness,
  bool pureDark,
) {
  final isDark = brightness == Brightness.dark;

  // NOTE: Calculate Background Color (Subtle tint of primary)
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
    state =
        AppPreferences.getPreferenceBool(AppPreferences.keyDoubleTapToExit) ??
        false;
  }

  Future<void> toggle() async {
    state = !state;
    await AppPreferences.setPreferenceBool(
      AppPreferences.keyDoubleTapToExit,
      state,
    );
  }
}

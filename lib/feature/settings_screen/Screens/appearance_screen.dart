import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';
import 'package:fuck_your_todos/core/theme/app_themes.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final currentPreset = themeState.preset;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'COLOR SCHEMES',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: AppThemes.presets.map((preset) {
                    final isSelected = currentPreset.name == preset.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ThemePreviewCard(
                        preset: preset,
                        isSelected: isSelected,
                        pureDark: themeState.pureDark,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              _ThemeModeSelector(themeMode: themeMode, colorScheme: cs),
              const _PureDarkToggle(),
              const _LanguageSelector(),
              const _DoubleTapExitToggle(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// NOTE: this widget is used to preview the color schemes
class _ThemePreviewCard extends ConsumerWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final bool pureDark;

  const _ThemePreviewCard({
    required this.preset,
    required this.isSelected,
    required this.pureDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate preview scheme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewCs = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Theme.of(context).brightness,
    );

    final cardBg = isDark && pureDark ? Colors.black : previewCs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            ref.read(themeProvider.notifier).setPreset(preset);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            height: 160,
            width: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? previewCs.primary
                    : previewCs.outlineVariant,
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: _PreviewContent(previewCs: previewCs, preset: preset),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          preset.name,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PreviewContent extends StatelessWidget {
  final ColorScheme previewCs;
  final AppThemePreset preset;

  const _PreviewContent({required this.previewCs, required this.preset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fake App Bar / Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 10,
              width: 40,
              decoration: BoxDecoration(
                color: previewCs.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: previewCs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _buildFakeTask(previewCs, 0.8),
        const SizedBox(height: 8),
        _buildFakeTask(previewCs, 0.5),
        const SizedBox(height: 8),
        _buildFakeTask(previewCs, 0.7, isCompleted: true),

        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: previewCs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: previewCs.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 16,
              color: previewCs.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFakeTask(
    ColorScheme cs,
    double widthFactor, {
    bool isCompleted = false,
  }) {
    return Row(
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 12,
            color: isCompleted ? cs.primary : cs.outlineVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted ? cs.outline : cs.onSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// NOTE: this widget is used to select the theme mode
/// modes: system, light, dark
class _ThemeModeSelector extends ConsumerWidget {
  final ThemeMode themeMode;
  final ColorScheme colorScheme;

  const _ThemeModeSelector({
    required this.themeMode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Theme Mode',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _themeModeLabel(themeMode),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<ThemeMode>(
        initialValue: themeMode,
        onSelected: (mode) {
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: colorScheme.surfaceContainerHighest,
        itemBuilder: (context) => [
          _buildThemeItem(context, ThemeMode.system, 'System', themeMode),
          _buildThemeItem(context, ThemeMode.light, 'Light', themeMode),
          _buildThemeItem(context, ThemeMode.dark, 'Dark', themeMode),
        ],
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_drop_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Converts enum -> label
  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
    }
  }

  PopupMenuItem<ThemeMode> _buildThemeItem(
    BuildContext context,
    ThemeMode value,
    String label,
    ThemeMode currentMode,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = currentMode == value;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_rounded, size: 16, color: cs.primary),
        ],
      ),
    );
  }
}

/// NOTE: this widget is used to toggle pure dark mode
/// pure dark mode uses less power on AMOLED screens
class _PureDarkToggle extends ConsumerWidget {
  const _PureDarkToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pureDark = ref.watch(themeProvider).pureDark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: isDark ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          'Pure Dark',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Uses less power on AMOLED screens',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: pureDark,
          onChanged: isDark
              ? (value) {
                  ref.read(themeProvider.notifier).togglePureDark();
                }
              : null,
        ),
      ),
    );
  }
}

/// NOTE: this widget is used to select the language
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Language',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Change system language for app',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.language_rounded),
      onTap: () {
        AppSettings.openAppSettings(type: AppSettingsType.settings);
      },
    );
  }
}

/// NOTE: this widget is used to toggle double tap to exit
/// double tap to exit is a feature that allows the user to
/// exit the app by double tapping on the home screen
class _DoubleTapExitToggle extends ConsumerWidget {
  const _DoubleTapExitToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleTap = ref.watch(doubleTapToExitProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Double Tap to Exit',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Press twice on home screen to exit',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: doubleTap,
        onChanged: (value) {
          ref.read(doubleTapToExitProvider.notifier).toggle();
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/app_themes.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';

class OnboardingThemeWidget extends ConsumerWidget {
  const OnboardingThemeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final currentPreset = themeState.preset;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Theme Settings',
          //   style: Theme.of(
          //     context,
          //   ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          //   textAlign: TextAlign.left,
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Configure how your app looks and feels.',
          //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //     color: Theme.of(context).colorScheme.onSurfaceVariant,
          //   ),
          //   textAlign: TextAlign.left,
          // ),
          // const SizedBox(height: 32),
          Text(
            'COLOR SCHEMES',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: AppThemes.presets.map((preset) {
              final isSelected = currentPreset.name == preset.name;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _OnboardingThemePreviewCard(
                  preset: preset,
                  isSelected: isSelected,
                  pureDark: themeState.pureDark,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          _OnboardingThemeModeSelector(themeMode: themeMode, colorScheme: cs),
          const SizedBox(height: 8),
          const _OnboardingPureDarkToggle(),
        ],
      ),
    );
  }
}

class _OnboardingThemePreviewCard extends ConsumerWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final bool pureDark;

  const _OnboardingThemePreviewCard({
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
            height: 120,
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? previewCs.primary
                    : previewCs.outlineVariant,
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: _PreviewContent(previewCs: previewCs, preset: preset),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          preset.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 8,
              width: 30,
              decoration: BoxDecoration(
                color: previewCs.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: previewCs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFakeTask(previewCs, 0.8),
        const SizedBox(height: 6),
        _buildFakeTask(previewCs, 0.5),
        const SizedBox(height: 6),
        _buildFakeTask(previewCs, 0.7, isCompleted: true),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: previewCs.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 12,
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
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 8,
            color: isCompleted ? cs.primary : cs.outlineVariant,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isCompleted ? cs.outline : cs.onSurface,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(1),
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

class _OnboardingThemeModeSelector extends ConsumerWidget {
  final ThemeMode themeMode;
  final ColorScheme colorScheme;

  const _OnboardingThemeModeSelector({
    required this.themeMode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
        onSelected: (mode) =>
            ref.read(themeProvider.notifier).setThemeMode(mode),
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: colorScheme.surfaceContainerHighest,
        itemBuilder: (context) => [
          _buildThemeItem(context, ThemeMode.system, 'System', themeMode),
          _buildThemeItem(context, ThemeMode.light, 'Light', themeMode),
          _buildThemeItem(context, ThemeMode.dark, 'Dark', themeMode),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _themeModeLabel(themeMode),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

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

class _OnboardingPureDarkToggle extends ConsumerWidget {
  const _OnboardingPureDarkToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pureDark = ref.watch(themeProvider).pureDark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: isDark ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
              ? (_) => ref.read(themeProvider.notifier).togglePureDark()
              : null,
        ),
      ),
    );
  }
}

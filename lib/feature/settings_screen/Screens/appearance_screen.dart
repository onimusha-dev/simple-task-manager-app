import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';
import 'package:fuck_your_todos/core/theme/AppThemes.dart';

/// 🎨 Appearance settings screen
/// Japanese hint:
/// 外観 (がいかん / gaikan) = appearance
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 Watch providers once (avoid repetition)
    final themeMode = ref.watch(themeControllerProvider);
    final currentPreset = ref.watch(themePresetProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// =======================
            /// 🎨 Color Scheme Header
            /// =======================
            Text(
              'Color Schemes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// 🎨 Preset Horizontal List
            /// =======================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: AppThemes.presets.map((preset) {
                  final isSelected = currentPreset.name == preset.name;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _ThemePreviewCard(
                      preset: preset,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// =======================
            /// 🌗 Theme Mode Selector
            /// =======================
            _ThemeModeSelector(themeMode: themeMode, colorScheme: cs),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  final ThemeMode themeMode;
  final ColorScheme colorScheme;

  const _ThemeModeSelector({
    required this.themeMode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Theme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          PopupMenuButton<ThemeMode>(
            initialValue: themeMode,
            onSelected: (mode) {
              ref.read(themeControllerProvider.notifier).setTheme(mode);
            },
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: colorScheme.surfaceContainerHighest,
            itemBuilder: (context) => [
              _buildThemeItem(context, ThemeMode.system, 'System', themeMode),
              _buildThemeItem(context, ThemeMode.light, 'Light', themeMode),
              _buildThemeItem(context, ThemeMode.dark, 'Dark', themeMode),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _themeModeLabel(themeMode),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧠 Converts enum → label
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
              style: TextStyle(
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

class _ThemePreviewCard extends ConsumerWidget {
  final AppThemePreset preset;
  final bool isSelected;

  const _ThemePreviewCard({required this.preset, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎨 Generate preview scheme
    final previewCs = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Theme.of(context).brightness,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            ref.read(themePresetProvider.notifier).setPreset(preset);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            height: 160,
            width: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: previewCs.surface,
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
        // 🔹 Fake App Bar / Header
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

        // 🔹 Fake Content Item 1
        _buildFakeTask(previewCs, 0.8),
        const SizedBox(height: 8),

        // 🔹 Fake Content Item 2
        _buildFakeTask(previewCs, 0.5),
        const SizedBox(height: 8),

        // 🔹 Fake Content Item 3 (Completed)
        _buildFakeTask(previewCs, 0.7, isCompleted: true),

        const Spacer(),

        // 🔹 Fake Floating Action Button
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

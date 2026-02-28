import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/app_themes.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';

class OnboardingThemeWidget extends ConsumerWidget {
  const OnboardingThemeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final currentPreset = themeState.preset;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHOOSE YOUR STYLE',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          // Pinterest-style Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: AppThemes.presets.length,
            itemBuilder: (context, index) {
              final preset = AppThemes.presets[index];
              final isSelected = currentPreset.name == preset.name;

              return _OnboardingThemePreviewCard(
                preset: preset,
                isSelected: isSelected,
                pureDark: themeState.pureDark,
              );
            },
          ),
          const SizedBox(height: 32),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              ref.read(themeProvider.notifier).setPreset(preset);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
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
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: previewCs.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: _PreviewContent(previewCs: previewCs, preset: preset),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          preset.name,
          textAlign: TextAlign.center,
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

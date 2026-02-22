// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fuck_your_todos/core/theme/AppThemes.dart';
// import 'package:fuck_your_todos/core/theme/theme_provider.dart';

// class _ThemePreviewCard extends ConsumerWidget {
//   final AppThemePreset preset;
//   final bool isSelected;

//   const _ThemePreviewCard({
//     required this.preset,
//     required this.isSelected,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 🎨 Generate preview scheme
//     final previewCs = ColorScheme.fromSeed(
//       seedColor: preset.seedColor,
//       brightness: Theme.of(context).brightness,
//     );

//     return Column(
//       children: [
//         InkWell(
//           onTap: () {
//             ref.read(themePresetProvider.notifier).setPreset(preset);
//           },
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             height: 190,
//             width: 140,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: previewCs.surface,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: isSelected
//                     ? previewCs.primary
//                     : previewCs.outlineVariant,
//                 width: isSelected ? 1 : 0.5,
//               ),
//             ),
//             child: _PreviewContent(previewCs: previewCs, preset: preset),
//           ),
//         ),

//         const SizedBox(height: 10),

//         Text(
//           preset.name,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//       ],
//     );
//   }
// }

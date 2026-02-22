# App Styling Guide

This document describes the design system and styling standards used in this application.

## Typography

We use the Material 3 `TextTheme` globally to ensure consistency across the application. NEVER hardcode `TextStyle` sizes or weights unless making a tiny modification to a global theme.

*   **Headers (`Theme.of(context).textTheme.titleLarge` / `titleMedium`)**: Used for page titles, section headers, and prominent list tile titles. Usually combined with `.copyWith(fontWeight: FontWeight.bold)`.
*   **Body Content (`Theme.of(context).textTheme.bodyLarge` / `bodyMedium`)**: Used for the primary content, such as labels, list tile subtitles, or descriptions.

## Colors

All colors must come directly from the active `ColorScheme` via `Theme.of(context).colorScheme`. Avoid hardcoded Hex or ARGB values in UI components.

*   `colorScheme.onSurface`: Default text color for primary info.
*   `colorScheme.onSurfaceVariant`: Default text color for secondary info (like subtitles).
*   `colorScheme.primary`: Highlight colors and selected states.

## Layout Configuration

*   **Padding**: General padding for screens shouldn't be hardcoded to irregular numbers. Use `16.0` (or `EdgeInsets.all(16)`) for screen bounds.
*   **ListTiles**: When constructing vertical menus (like settings screens), prefer using `ListTile`. We add `contentPadding: const EdgeInsets.symmetric(horizontal: 16)` to make them flush with our general styling. 

## Theming Engine
The app leverages Riverpod and `DynamicColorBuilder`. There are several aspects to its configuration:

1.  **Pure Dark Mode**: Controlled via `pureDarkProvider`. When active (and system is dark), `scaffoldBackgroundColor` is forced to `Colors.black` to save AMOLED battery.
2.  **Seed Blending**: When "Pure Dark" is off, the `scaffoldBackgroundColor` is derived by taking a default surface color and alpha-blending `3%` to `5%` of the active `primary` seed color into it, giving the app a gorgeous, subtle tint.
3.  **Dynamic Colors**: The `Dynamic` preset looks at the Android System's materialized color palette. If the system supports it, it seamlessly hooks into those. Otherwise, it falls back to a curated list of static seed colors (`AppThemes.dart`).

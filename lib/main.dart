import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';
import 'package:fuck_your_todos/main_app_screen.dart';
import 'package:fuck_your_todos/feature/error_screen/global_error_screen.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:fuck_your_todos/feature/onboarding/onboarding_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIChangeCallback((bool visible) async {
    if (visible) {
      await Future.delayed(const Duration(milliseconds: 2500));
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    }
  });

  // Catch Flutter UI errors and substitute the broken widget tree with our error screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(errorDetails: details);
  };

  runApp(Phoenix(child: ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final preset = themeState.preset;
    final pureDark = themeState.pureDark;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (preset.useDynamic && lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic;
          darkScheme = darkDynamic;
        } else {
          lightScheme = ColorScheme.fromSeed(seedColor: preset.seedColor);

          darkScheme = ColorScheme.fromSeed(
            seedColor: preset.seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: buildTheme(lightScheme, Brightness.light, false),
          darkTheme: buildTheme(darkScheme, Brightness.dark, pureDark),
          themeMode: themeMode,
          home:
              (AppPreferences.getPreferenceBool(
                    AppPreferences.keyOnboardingCompleted,
                  ) ??
                  false)
              ? const MainAppScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}

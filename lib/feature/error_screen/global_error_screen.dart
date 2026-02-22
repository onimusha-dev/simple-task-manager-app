import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorScreen({super.key, required this.errorDetails});

  Future<void> _reportError() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'musaddikulislam007@gmail.com',
      queryParameters: {
        'subject': 'App Bug Report',
        'body':
            'App encountered a fatal error:\n\n'
            'Exception: ${errorDetails.exceptionAsString()}\n'
            'StackTrace:\n${errorDetails.stack}\n',
      },
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      debugPrint('Could not launch email target.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // We return a completely separated MaterialApp here so that the Error Screen
    // looks correct even if the inherited Theme or Directionality is broken by the crash!
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), // Dark safe fallback background
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 96,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oh snap! Something broke.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'An unexpected error occurred. Please report this to help us fix the issue, or try relaunching the application.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _reportError,
                        icon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Report Error',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Trigger the global restart routine at the root level!
                          AppRestarter.restartApp(context);
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Relaunch App',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper to restart the entire app tree from scratch when instructed.
class AppRestarter extends StatefulWidget {
  final Widget child;

  const AppRestarter({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestarterState>()?.restartApp();
  }

  @override
  State<AppRestarter> createState() => _AppRestarterState();
}

class _AppRestarterState extends State<AppRestarter> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey(); // Re-creates the whole underlying tree!
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

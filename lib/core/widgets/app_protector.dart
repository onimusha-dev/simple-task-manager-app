import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:fuck_your_todos/core/widgets/pin_screen.dart';

class AppProtector extends StatefulWidget {
  final Widget child;

  const AppProtector({super.key, required this.child});

  @override
  State<AppProtector> createState() => _AppProtectorState();
}

class _AppProtectorState extends State<AppProtector>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isLocallyProtected = false;
  bool _isAuthenticating = false;
  String _protectionType = 'biometrics';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkProtection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkProtection() {
    setState(() {
      _isLocallyProtected =
          AppPreferences.getBool(AppPreferences.keyAppProtectionEnabled) ??
          false;
      _protectionType =
          AppPreferences.getString(AppPreferences.keyAppProtectionType) ??
          'biometrics';
      if (!_isLocallyProtected) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    });

    if (_isLocallyProtected && !_isAuthenticated && _protectionType != 'pin') {
      _authenticate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkProtection();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isLocallyProtected) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
    });

    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access your journal',
        biometricOnly: false,
        sensitiveTransaction: true,
      );
    } catch (e) {
      // Handle error, maybe they don't have biometrics/pin.
      authenticated = false;
    }

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = authenticated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocallyProtected) {
      return widget.child;
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    if (_protectionType == 'pin') {
      return Scaffold(
        body: PinScreen(
          isSettingPin: false,
          onSuccess: () {
            if (mounted) {
              setState(() {
                _isAuthenticated = true;
              });
            }
          },
          onCancel: () {
            // Cannot cancel app unlock
          },
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'App Locked',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please authenticate to continue',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _isAuthenticating ? null : _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

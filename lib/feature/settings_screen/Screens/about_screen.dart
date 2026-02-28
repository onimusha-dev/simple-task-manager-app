import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _allowUnstableUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'App Info'),
              const SizedBox(height: 8),
              _ListViewItem(
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.info_outline_rounded,
                onTap: () async {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Version 1.0.0 is up to date',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                          ),
                        );
                      }
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to check for updates',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                          duration: const Duration(seconds: 3),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Allow unstable updates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Receive beta and pre-release versions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(
                  value: _allowUnstableUpdates,
                  onChanged: (value) {
                    setState(() {
                      _allowUnstableUpdates = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              const _SectionHeader(title: 'Community & Source'),
              _ListViewItem(
                title: 'Source code',
                subtitle: 'View the source code on GitHub',
                icon: Icons.code_rounded,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/onimusha-dev/simple-task-manager-app',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              _ListViewItem(
                title: 'Telegram group',
                subtitle: 'Join the community and chat with others',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  launchUrl(
                    Uri.parse('https://t.me/+3sRfr-qGQ4BkZDRl'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Note: move this page to a file in core
/// useage: this should be used in places
/// where the list item are just btns with icon and text
/// and no other functionality
///
/// we might use this as a template for other settings pages
/// when it happens move this widget to that file too
class _ListViewItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ListViewItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

/// NOTE: helper widget to create a section header
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

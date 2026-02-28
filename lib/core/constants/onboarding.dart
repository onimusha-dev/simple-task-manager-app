import 'package:flutter/material.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingConstants {
  static final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Journal',
      description:
          'Capture your thoughts, daily plans, and organize your life effortlessly.',
      icon: Icons.menu_book_rounded,
    ),
    OnboardingPage(
      title: 'Theme Settings',
      description: 'Configure how your app looks and feels.',
      icon: Icons.palette_rounded,
    ),
    OnboardingPage(
      title: 'Stay Informed',
      description:
          'Allow notifications to receive timely reminders directly to your device.',
      icon: Icons.notifications_active_rounded,
    ),
    OnboardingPage(
      title: 'Your Data is Secure',
      description:
          'Keep your data safe with native local backups and easy restores. You hold the keys.',
      icon: Icons.lock_outline_rounded,
    ),
    OnboardingPage(
      title: 'All Set!',
      description:
          'Thank you for choosing us. Let\'s get started on your organized journey.',
      icon: Icons.celebration_rounded,
    ),
  ];
}

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
      title: 'Manage your tasks',
      description:
          'You can easily manage all of your daily tasks in AnyTask for free',
      icon: Icons.task_alt,
    ),
    OnboardingPage(
      title: 'Create daily routine',
      description:
          'In AnyTask you can create your personalized routine to stay productive',
      icon: Icons.calendar_today,
    ),
    OnboardingPage(
      title: 'Organize your tasks',
      description:
          'You can organize your daily tasks by adding your tasks into separate categories',
      icon: Icons.folder_outlined,
    ),
  ];
}

class MotivationConstants {
  static const List<String> quotes = [
    "Small steps lead to big results.",
    "Focus on being productive instead of busy.",
    "The secret of getting ahead is getting started.",
    "It’s not about having time. It’s about making time.",
    "Don't count the days, make the days count.",
    "Productivity is never an accident.",
    "Starve your distractions, feed your focus.",
    "Your future is created by what you do today.",
  ];
}

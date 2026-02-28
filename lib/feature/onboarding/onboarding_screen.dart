import 'package:flutter/material.dart';
import 'package:fuck_your_todos/core/constants/onboarding.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:fuck_your_todos/main_app_screen.dart';
import 'package:fuck_your_todos/feature/onboarding/widgets/onboarding_page_widget.dart';
import 'package:fuck_your_todos/feature/onboarding/widgets/onboarding_theme_widget.dart';
import 'package:fuck_your_todos/feature/onboarding/widgets/onboarding_notification_widget.dart';
import 'package:fuck_your_todos/feature/onboarding/widgets/onboarding_backup_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage == OnboardingConstants.pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await AppPreferences.setPreferenceBool(
      AppPreferences.keyOnboardingCompleted,
      true,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainAppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == OnboardingConstants.pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background placeholder for default theme styling
          Container(color: theme.colorScheme.surface),

          // Full-screen background image for the last onboarding screen
          AnimatedOpacity(
            opacity: isLastPage ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Dark gradient overlay to ensure text is readable
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: isLastPage ? null : _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: isLastPage
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingConstants.pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = OnboardingConstants.pages[index];

                      // Specifically render Theme Widget on slide 1
                      if (index == 1) {
                        return const OnboardingThemeWidget();
                      }

                      // Specifically render Notification Widget on slide 2
                      if (index == 2) {
                        return const OnboardingNotificationWidget();
                      }

                      // Specifically render Backup Widget on slide 3
                      if (index == 3) {
                        return const OnboardingBackupWidget();
                      }

                      // Render default Icon+Text layout otherwise
                      return OnboardingPageWidget(
                        icon: page.icon,
                        title: page.title,
                        description: page.description,
                        isLastPage: isLastPage,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          OnboardingConstants.pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 10,
                            width: _currentPage == index ? 24 : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? (isLastPage
                                        ? Colors.white
                                        : theme.colorScheme.primary)
                                  : (isLastPage
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : theme.colorScheme.primary.withValues(
                                            alpha: 0.2,
                                          )),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                      AnimatedTheme(
                        data: isLastPage ? ThemeData.dark() : Theme.of(context),
                        child: FilledButton(
                          onPressed: _onNext,
                          style: FilledButton.styleFrom(
                            backgroundColor: isLastPage
                                ? Colors.white
                                : theme.colorScheme.primary,
                            foregroundColor: isLastPage
                                ? Colors.black
                                : theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: TextStyle(
                              fontWeight: isLastPage
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

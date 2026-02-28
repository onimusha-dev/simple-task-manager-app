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
  double _scrollOffset = 0.0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _scrollOffset = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    final totalPages = OnboardingConstants.pages.length;
    final lastPageIndex = totalPages - 1;

    // Calculate background opacity based on how close we are to the last page
    // Starts fading in when moving from second-to-last to last
    final backgroundOpacity = (_scrollOffset - (lastPageIndex - 1)).clamp(
      0.0,
      1.0,
    );
    final isLastPage = _currentPage == lastPageIndex;

    return Scaffold(
      body: Stack(
        children: [
          // Base background color
          Container(color: theme.colorScheme.surface),

          // Smooth background image transition
          Opacity(
            opacity: backgroundOpacity,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black, // Dark base for the image
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/1.png',
                    fit: BoxFit.contain, // Avoid cropping, fit within screen
                    alignment: Alignment.center,
                  ),
                  // Gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button - fades out as we reach the end
                Opacity(
                  opacity: (1.0 - backgroundOpacity).clamp(0.0, 1.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: backgroundOpacity > 0.5
                          ? null
                          : _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalPages,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = OnboardingConstants.pages[index];
                      final bool isCurrentlyLast = index == lastPageIndex;

                      Widget content;
                      if (index == 1) {
                        content = const OnboardingThemeWidget();
                      } else if (index == 2) {
                        content = const OnboardingNotificationWidget();
                      } else if (index == 3) {
                        content = const OnboardingBackupWidget();
                      } else {
                        content = OnboardingPageWidget(
                          icon: page.icon,
                          title: page.title,
                          description: page.description,
                          isLastPage: isCurrentlyLast,
                        );
                      }

                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: content,
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators
                      Row(
                        children: List.generate(totalPages, (index) {
                          // Interpolate color between theme primary and white
                          final activeColor = Color.lerp(
                            theme.colorScheme.primary,
                            Colors.white,
                            backgroundOpacity,
                          );
                          final inactiveColor = Color.lerp(
                            theme.colorScheme.primary.withOpacity(0.2),
                            Colors.white.withOpacity(0.3),
                            backgroundOpacity,
                          );

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 10,
                            width: _currentPage == index ? 24 : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? activeColor
                                  : inactiveColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          );
                        }),
                      ),

                      // Action Button
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _onNext,
                          style: FilledButton.styleFrom(
                            backgroundColor: Color.lerp(
                              theme.colorScheme.primary,
                              Colors.white,
                              backgroundOpacity,
                            ),
                            foregroundColor: Color.lerp(
                              theme.colorScheme.onPrimary,
                              Colors.black,
                              backgroundOpacity,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

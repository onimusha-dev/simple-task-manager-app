
import 'package:flutter/material.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/feature/home_screen/introduction/create_or_login_screen.dart';
import 'package:fuck_your_todos/main_app_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  final List<OnboardingPage> pages = OnboardingConstants.pages;

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Navigate to welcome screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Screen4()),
      );
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = pages[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainAppScreen(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'SKIP',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Illustration
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                currentPage.icon,
                size: 150,
                color: const Color(0xFF6366F1),
              ),
            ),

            const SizedBox(height: 40),

            // Progress Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: index == currentIndex ? 26 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: index == currentIndex
                        ? Colors.white
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),

            const SizedBox(height: 50),

            // Title and Description
            SizedBox(
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    currentPage.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      currentPage.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Back and Next Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 90,
                    height: 48,
                    child: currentIndex > 0
                        ? TextButton(
                            onPressed: previousPage,
                            style: TextButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'BACK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  SizedBox(
                    width: pages.length - 1 == currentIndex ? 160 : 90,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        pages.length - 1 == currentIndex
                            ? 'GET STARTED'
                            : 'NEXT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }
}

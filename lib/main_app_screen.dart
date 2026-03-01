import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';
import 'package:fuck_your_todos/feature/calender_screen/provider/calendar_date_provider.dart';
import 'package:fuck_your_todos/feature/calender_screen/calender_screen.dart';
import 'package:fuck_your_todos/feature/error_screen/test.dart';
import 'package:fuck_your_todos/feature/home_screen/home_screen.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note_view.dart';
import 'package:fuck_your_todos/feature/profile_screen/analytics_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/settings_screen.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainAppScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  DateTime? currentBackPressTime;
  late int currentIndex;
  final List<Widget> pages = [
    HomeScreen(),
    CalendarScreen(),
    TestScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final doubleTapToExit = ref.watch(doubleTapToExitProvider);

    return PopScope(
      canPop: !doubleTapToExit,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: currentIndex == 1
            ? null
            : PreferredSize(
                preferredSize: Size(double.infinity, 56),
                child: AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                      ),
                    ],
                  ),
                ),
              ),
        body: SafeArea(bottom: false, child: pages[currentIndex]),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                // Theme.of(context).colorScheme.primary,
                // Theme.of(context).colorScheme.secondary,
                Colors.blue,
                Colors.red,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final initialDate = currentIndex == 1
                    ? ref.read(selectedCalendarDateProvider)
                    : null;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return CreateNoteView(initialDate: initialDate);
                  },
                );
              },
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ),

        bottomNavigationBar: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: BottomAppBar(
            height: 64,
            padding: EdgeInsets.zero,
            notchMargin: 10,
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: CupertinoIcons.house,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: CupertinoIcons.calendar,
                    activeIcon: CupertinoIcons.calendar_today,
                    label: 'Calendar',
                  ),
                  const SizedBox(width: 80), // Space for FAB
                  _buildTabItem(
                    index: 2,
                    icon: CupertinoIcons.timer,
                    activeIcon: CupertinoIcons.timer_fill,
                    label: 'Focus',
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: CupertinoIcons.chart_bar,
                    activeIcon: CupertinoIcons.chart_bar_fill,
                    label: 'Analytics',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// NOTE: widget for building bottom nav bar options
  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return Opacity(
      opacity: isSelected ? 1.0 : 0.5,
      child: InkWell(
        onTap: () => _switchTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/calender_screen/calendar_date_provider.dart';
import 'package:fuck_your_todos/feature/calender_screen/calender_screen.dart';
import 'package:fuck_your_todos/feature/home_screen/home_screen.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note_view.dart';
import 'package:fuck_your_todos/feature/profile_screen/profile_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/settings_screen.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainAppScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  late int currentIndex;
  final List<Widget> pages = [
    HomeScreen(),
    CalendarScreen(),
    // // FocusScreen(),
    // Placeholder(),
    // ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      icon: Row(
                        children: [
                          Text(
                            '🔥677',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.person),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: SafeArea(child: pages[currentIndex]),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // When on the Calendar tab (index 1), pre-fill the due date with
          // the currently selected calendar date. Otherwise no pre-fill.
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
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),

      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Opacity(
              opacity: currentIndex == 0 ? 1.0 : 0.5,
              child: SizedBox(
                width: 70,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _switchTab(0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, size: 24),
                        SizedBox(height: 4),
                        Text('Home', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: currentIndex == 1 ? 1.0 : 0.5,
              child: SizedBox(
                width: 70,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _switchTab(1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 24),
                        SizedBox(height: 4),
                        Text('Calendar', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.0, width: 24.0),
            Opacity(
              opacity: currentIndex == 2 ? 1.0 : 0.5,
              child: SizedBox(
                width: 70,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _switchTab(2),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, size: 24),
                        SizedBox(height: 4),
                        Text('Focus', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: currentIndex == 3 ? 1.0 : 0.5,
              child: SizedBox(
                width: 70,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _switchTab(3),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 24),
                        SizedBox(height: 4),
                        Text('Profile', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekCarouselWidget extends ConsumerStatefulWidget {
  const WeekCarouselWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.weekStartDate,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.selectedTextColor,
  });

  /// Currently selected date
  final DateTime selectedDate;

  /// Callback when a date is selected
  final ValueChanged<DateTime> onDateSelected;

  /// Starting date of the week to display (defaults to current week's start)
  final DateTime? weekStartDate;

  /// Background color for selected date
  final Color? selectedColor;

  /// Background color for unselected dates
  final Color? unselectedColor;

  /// Text color for unselected dates
  final Color? textColor;

  /// Text color for selected date
  final Color? selectedTextColor;

  @override
  ConsumerState<WeekCarouselWidget> createState() => _WeekCarouselWidgetState();
}

class _WeekCarouselWidgetState extends ConsumerState<WeekCarouselWidget> {
  late DateTime _initialWeekStart;
  late PageController _pageController;
  int _currentPageIndex = 100;

  static const List<String> _dayNames = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  @override
  void initState() {
    super.initState();
    _initialWeekStart =
        widget.weekStartDate ?? _getWeekStart(widget.selectedDate);
    _pageController = PageController(
      initialPage: 100,
    ); // Start at middle for infinite scroll
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Returns the Sunday of the week containing the given date
  /// Dart's weekday: Monday = 1, Sunday = 7
  DateTime _getWeekStart(DateTime date) {
    // If Sunday (weekday == 7), subtract 0 days
    // If Monday (weekday == 1), subtract 1 day
    // If Saturday (weekday == 6), subtract 6 days
    final daysToSubtract = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Get the week starting from an offset (for infinite scrolling)
  DateTime _getWeekFromOffset(int offset) {
    return _initialWeekStart.add(Duration(days: (offset - 100) * 7));
  }

  /// Get current displayed week start based on page index
  DateTime _getCurrentWeekStart() {
    return _getWeekFromOffset(_currentPageIndex);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor = widget.unselectedColor ?? Colors.transparent;
    final textColor = widget.textColor ?? theme.colorScheme.onSurface;
    final selectedTextColor =
        widget.selectedTextColor ?? theme.colorScheme.onPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month/Year Header with navigation
        _buildHeader(),
        const SizedBox(height: 8),
        // Week Days Carousel
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final weekStart = _getWeekFromOffset(pageIndex);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (dayIndex) {
                  final date = weekStart.add(Duration(days: dayIndex));
                  final isSelected = _isSameDay(date, widget.selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: () => widget.onDateSelected(date),
                    child: _buildDayItem(
                      dayName: _dayNames[dayIndex],
                      dayNumber: date.day,
                      isSelected: isSelected,
                      isToday: isToday,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      textColor: textColor,
                      selectedTextColor: selectedTextColor,
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final currentWeekStart = _getCurrentWeekStart();
    final monthNames = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Column(
            children: [
              Text(
                monthNames[currentWeekStart.month - 1],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${currentWeekStart.year}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required String dayName,
    required int dayNumber,
    required bool isSelected,
    required bool isToday,
    required Color selectedColor,
    required Color unselectedColor,
    required Color textColor,
    required Color selectedTextColor,
  }) {
    final isSaturday = dayName == 'SAT';
    final isSunday = dayName == 'SUN';

    Color dayTextColor = textColor;
    if (isSaturday) {
      dayTextColor = Theme.of(context).colorScheme.secondary;
    } else if (isSunday) {
      dayTextColor = Theme.of(context).colorScheme.error;
    }

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : unselectedColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday && !isSelected
            ? Border.all(color: selectedColor, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? selectedTextColor : dayTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dayNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? selectedTextColor : textColor,
            ),
          ),
        ],
      ),
    );
  }
}

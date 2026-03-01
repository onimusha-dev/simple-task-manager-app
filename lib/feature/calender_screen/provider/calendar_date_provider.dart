import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that tracks the date currently selected in the Calendar screen.
///
/// Defaults to today. Updated whenever the user taps a new day in
/// [WeekCarouselWidget]. [CreateNoteView] reads this when opened from the
/// calendar tab to pre-populate the due-date field.
class CalendarDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

final selectedCalendarDateProvider =
    NotifierProvider<CalendarDateNotifier, DateTime>(CalendarDateNotifier.new);

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

class AppConstants {
  static const String appName = 'Fuck Your Todos';
  static const String appVersion = '1.0.0';
}

class DatabaseConstants {
  static const String name = 'journal_app_db';

  // Drift appends '.sqlite' to the database name by default
  static const String fileName = '$name.sqlite';
  static const String walFileName = '$fileName-wal';
  static const String shmFileName = '$fileName-shm';
}

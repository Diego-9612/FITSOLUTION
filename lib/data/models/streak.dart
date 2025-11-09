class Streak {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompleted;

  Streak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompleted,
  });

  factory Streak.fromMap(Map<String, dynamic> m) => Streak(
        userId: m['user_id'],
        currentStreak: m['current_streak'],
        longestStreak: m['longest_streak'],
        lastCompleted: m['last_completed'] != null ? DateTime.parse(m['last_completed']) : null,
      );
}

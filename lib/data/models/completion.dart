class Completion {
  final String id;
  final String userId;
  final String exerciseId;
  final DateTime dateYmd;
  final bool done;

  Completion({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.dateYmd,
    required this.done,
  });

  factory Completion.fromMap(Map<String, dynamic> m) => Completion(
        id: m['id'],
        userId: m['user_id'],
        exerciseId: m['exercise_id'],
        dateYmd: DateTime.parse(m['date_ymd']),
        done: m['done'],
      );
}

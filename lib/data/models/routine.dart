class Routine {
  final String id;
  final String userId;
  final String title;
  final bool isActive;

  Routine({
    required this.id,
    required this.userId,
    required this.title,
    required this.isActive,
  });

  factory Routine.fromMap(Map<String, dynamic> m) => Routine(
        id: m['id'],
        userId: m['user_id'],
        title: m['title'],
        isActive: m['is_active'],
      );
}

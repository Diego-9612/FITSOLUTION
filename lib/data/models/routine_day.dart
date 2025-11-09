class RoutineDay {
  final String id;
  final String routineId;
  final int weekday; 
  final String split; 
  final int position;

  RoutineDay({
    required this.id,
    required this.routineId,
    required this.weekday,
    required this.split,
    required this.position,
  });

  factory RoutineDay.fromMap(Map<String, dynamic> m) => RoutineDay(
        id: m['id'],
        routineId: m['routine_id'],
        weekday: m['weekday'],
        split: m['split'],
        position: m['position'],
      );
}

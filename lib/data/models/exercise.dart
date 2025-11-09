class Exercise {
  final String id;
  final String routineDayId;
  final String name;
  final List<String> muscleGroups;
  final String? description;
  final String? howTo;
  final int sets;
  final String reps;

  Exercise({
    required this.id,
    required this.routineDayId,
    required this.name,
    required this.muscleGroups,
    this.description,
    this.howTo,
    required this.sets,
    required this.reps,
  });

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'],
        routineDayId: m['routine_day_id'],
        name: m['name'],
        muscleGroups: (m['muscle_groups'] as List).map((e) => e.toString()).toList(),
        description: m['description'],
        howTo: m['how_to'],
        sets: m['sets'],
        reps: m['reps'],
      );
}

class UserProfile {
  final String id;
  final double? heightCm;
  final double? weightKg;
  final String? somatotype; 
  final String? goal;       

  UserProfile({
    required this.id,
    this.heightCm,
    this.weightKg,
    this.somatotype,
    this.goal,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'],
        heightCm: (m['height_cm'] as num?)?.toDouble(),
        weightKg: (m['weight_kg'] as num?)?.toDouble(),
        somatotype: m['somatotype'],
        goal: m['goal'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'somatotype': somatotype,
        'goal': goal,
      };
}

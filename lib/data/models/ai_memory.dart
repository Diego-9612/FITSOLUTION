class AiMemory {
  final String id;
  final String userId;
  final Map<String, dynamic> memory;

  AiMemory({required this.id, required this.userId, required this.memory});

  factory AiMemory.fromMap(Map<String, dynamic> m) => AiMemory(
        id: m['id'],
        userId: m['user_id'],
        memory: Map<String, dynamic>.from(m['memory']),
      );
}

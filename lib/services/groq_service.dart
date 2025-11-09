import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';
import '../data/models/user_profile.dart';

class GroqService {
  final http.Client _http;
  GroqService({http.Client? client}) : _http = client ?? http.Client();

  Future<Map<String, dynamic>> generateRoutine({
    required UserProfile profile,
    required String memorySummary,
  }) async {
    final uri = Uri.parse('${AppEnv.groqBaseUrl}/chat/completions');
    final system = '''
Eres un planificador experto de entrenamiento basado en PPL (Push, Pull, Legs).
Responde SOLO en JSON válido con esta forma:
{
  "days": [
    {"weekday": 1, "split": "Push", "exercises": [
      {"name":"Press banca","muscle_groups":["Pectoral","Tríceps","Hombros"],"description":"...","how_to":"...","sets":4,"reps":"6-10"}
    ]}
  ]
}
Reglas:
- Días laborales: 1..5 (Lun a Vie) con orden PPL PULL LEGS PUSH PULL.
- 5 a 8 ejercicios por día.
- Adapta volumen e intensidad a somatotipo (${profile.somatotype}) y objetivo (${profile.goal}).
- Descripciones en español.
- No incluyas texto fuera del JSON.
''';

    final user = '''
Datos del usuario:
- Estatura: ${profile.heightCm?.toStringAsFixed(0)} cm
- Peso: ${profile.weightKg?.toStringAsFixed(1)} kg
- Somatotipo: ${profile.somatotype}
- Objetivo: ${profile.goal}
Memoria relevante: $memorySummary
Genera la rutina PPL de lunes a viernes.
''';

    final body = jsonEncode({
      "model": "llama-3.3-70b-versatile",
      "temperature": 0.3,
      "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": user}
      ],
      "response_format": {"type": "json_object"}
    });

    final res = await _http.post(
      uri,
      headers: {
        "Authorization": "Bearer ${AppEnv.groqApiKey}",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final String content = data['choices'][0]['message']['content'];
      return jsonDecode(content) as Map<String, dynamic>;
    } else {
      throw Exception('Groq error: ${res.statusCode} ${res.body}');
    }
  }
}

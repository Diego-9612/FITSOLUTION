import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_profile.dart';
import '../../../services/groq_service.dart';
import '../../../data/repositories/ai_memory_repository.dart';
import '../../../data/repositories/routine_repository.dart';

class OnboardingFormScreen extends StatefulWidget {
  const OnboardingFormScreen({super.key});
  @override
  State<OnboardingFormScreen> createState() => _OnboardingFormScreenState();
}

class _OnboardingFormScreenState extends State<OnboardingFormScreen> {
  final heightC = TextEditingController();
  final weightC = TextEditingController();
  String? somatotype;
  String? goal;
  bool loading = false;

  final somatos = const [
    {'k': 'mesomorfo', 'd': 'Cuerpo atlético; responde bien al entrenamiento.'},
    {'k': 'endomorfo', 'd': 'Tendencia a acumular grasa; mejor con volumen controlado.'},
    {'k': 'ectomorfo', 'd': 'Delgado; le cuesta ganar masa.'},
  ];
  final goals = const [
    {'k': 'definicion', 'd': 'Reducir grasa, preservar masa muscular.'},
    {'k': 'volumen', 'd': 'Ganar masa muscular con excedente calórico.'},
    {'k': 'mantenimiento', 'd': 'Mantener composición actual y rendimiento.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completa tu información para crear tu rutina personalizada.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estatura (cm)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 16),
            const Text('Somatotipo', style: TextStyle(fontWeight: FontWeight.bold)),
            ...somatos.map(
              (s) => RadioListTile<String>(
                title: Text('${s['k']} — ${s['d']}'),
                value: s['k']!,
                groupValue: somatotype,
                onChanged: (v) => setState(() => somatotype = v),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Objetivo', style: TextStyle(fontWeight: FontWeight.bold)),
            ...goals.map(
              (g) => RadioListTile<String>(
                title: Text('${g['k']} — ${g['d']}'),
                value: g['k']!,
                groupValue: goal,
                onChanged: (v) => setState(() => goal = v),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (heightC.text.isEmpty ||
                          weightC.text.isEmpty ||
                          somatotype == null ||
                          goal == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa todos los campos')),
                        );
                        return;
                      }
                      setState(() => loading = true);
                      try {
                        final client = Supabase.instance.client;
                        final user = client.auth.currentUser!;

                        
                        await client.from('profiles').upsert({
                          'id': user.id,
                          'height_cm': double.tryParse(heightC.text),
                          'weight_kg': double.tryParse(weightC.text),
                          'somatotype': somatotype,
                          'goal': goal,
                        });

                        final profile = UserProfile(
                          id: user.id,
                          heightCm: double.tryParse(heightC.text),
                          weightKg: double.tryParse(weightC.text),
                          somatotype: somatotype,
                          goal: goal,
                        );

                        
                        final memRepo = AiMemoryRepository(client);
                        final summary = await memRepo.getLatestSummary(user.id) ?? '';

                        
                        final groq = GroqService();
                        final routineJson = await groq.generateRoutine(
                          profile: profile,
                          memorySummary: summary,
                        );

                        
                        final routineRepo = RoutineRepository(client);

                        
                        await routineRepo.deactivateAllActives(user.id);

                        
                        final routineId =
                            await routineRepo.createRoutine(user.id, 'Rutina PPL');

                        
                        await routineRepo.clearRoutineDays(routineId);

                        
                        for (final day in (routineJson['days'] as List)) {
                          final weekday = day['weekday'] as int;
                          final split = day['split'] as String;
                          final exercises =
                              (day['exercises'] as List).cast<Map<String, dynamic>>();
                          final dayId = await routineRepo.addRoutineDay(
                            routineId: routineId,
                            weekday: weekday,
                            split: split,
                            position: weekday,
                          );
                          for (final ex in exercises) {
                            await routineRepo.addExercise(
                              routineDayId: dayId,
                              exercise: ex,
                            );
                          }
                        }

                        
                        await memRepo.saveRoutineContext(user.id, routineJson);

                        if (!mounted) return;
                        context.go('/');
                      } on PostgrestException catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error de base de datos: ${e.message}',
                            ),
                          ),
                        );
                        context.go('/');
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Hubo un problema generando tu rutina. Usaremos un plan base. Error: $e',
                            ),
                          ),
                        );
                        context.go('/');
                      } finally {
                        if (mounted) setState(() => loading = false);
                      }
                    },
              child: Text(loading ? 'Creando rutina...' : 'Crear rutina'),
            ),
          ],
        ),
      ),
    );
  }
}

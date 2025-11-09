import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/progress_repository.dart';

class RoutineDayScreen extends StatefulWidget {
  final Map<String, dynamic> day; 
  const RoutineDayScreen({super.key, required this.day});

  @override
  State<RoutineDayScreen> createState() => _RoutineDayScreenState();
}

class _RoutineDayScreenState extends State<RoutineDayScreen> {
  late final ConfettiController _confetti;
  late final ProgressRepository _repo;
  late final String _userId;
  final Map<String, bool> _checked = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    final client = Supabase.instance.client;
    _repo = ProgressRepository(client);
    _userId = client.auth.currentUser!.id;
    _init();
  }

  Future<void> _init() async {
    final today = DateTime.now();
    final exercises = (widget.day['exercises'] as List).cast<Map<String, dynamic>>();
    final existing = await _repo.getCompletionsForDate(userId: _userId, date: today);
    final byId = { for (final r in existing) r['exercise_id'] : r['done'] as bool };
    for (final ex in exercises) {
      _checked[ex['id']] = byId[ex['id']] ?? false;
    }
    setState(()=>loading=false);
  }

  Future<void> _toggle(String exId, bool value) async {
    final today = DateTime.now();
    await _repo.setCompletion(userId: _userId, exerciseId: exId, date: today, done: value);
    setState(()=>_checked[exId] = value);

    final allDone = _checked.values.every((v) => v);
    if (allDone) {
      _confetti.play();
      await _repo.updateStreakOnDayCompleted(_userId, today);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Día completado! ✨ Se sumó a tu racha.')));
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = (widget.day['exercises'] as List).cast<Map<String, dynamic>>();
    return Scaffold(
      appBar: AppBar(title: Text('Día ${widget.day['split']}')),
      body: Stack(children: [
        if (loading) const Center(child: CircularProgressIndicator())
        else ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final ex = exercises[i];
            final id = ex['id'] as String;
            final done = _checked[id] ?? false;
            return Card(
              child: ExpansionTile(
                title: Row(
                  children: [
                    Checkbox(value: done, onChanged: (v)=>_toggle(id, v ?? false)),
                    Expanded(child: Text(ex['name'] as String)),
                  ],
                ),
                children: [
                  ListTile(
                    title: const Text('¿Para qué sirve?'),
                    subtitle: Text(ex['description'] ?? '—'),
                  ),
                  ListTile(
                    title: const Text('¿Cómo se hace?'),
                    subtitle: Text(ex['how_to'] ?? '—'),
                  ),
                  ListTile(
                    title: const Text('Series y repeticiones'),
                    subtitle: Text('${ex['sets']} x ${ex['reps']}'),
                  ),
                  ListTile(
                    title: const Text('Grupos musculares'),
                    subtitle: Text(((ex['muscle_groups'] as List).join(', '))),
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false),
        ),
      ]),
    );
  }
}

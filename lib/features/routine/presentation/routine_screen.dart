import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/routine_repository.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Map<String, dynamic>> week = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    final repo = RoutineRepository(client);
    final r = await repo.getActiveRoutine(user.id);
    if (r == null) {
      if (!mounted) return;
      context.go('/onboarding');
      return;
    }
    final days = await repo.getRoutineForWeek(r['id']);
    setState(() {
      week = days;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Lun','Mar','Mié','Jue','Vie'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu rutina (PPL)'),
        actions: [
          IconButton(onPressed: ()=>context.go('/progress'), icon: const Icon(Icons.calendar_today)),
          IconButton(onPressed: ()=>context.go('/profile'), icon: const Icon(Icons.person)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>context.go('/onboarding'),
        label: const Text('Nueva rutina'),
        icon: const Icon(Icons.refresh),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: week.length,
              itemBuilder: (_, i) {
                final day = week[i];
                final split = day['split'];
                final exercises = (day['exercises'] as List);
                final label = tabs[(day['weekday'] as int) - 1];
                return Card(
                  child: ListTile(
                    title: Text('$label — $split'),
                    subtitle: Text('${exercises.length} ejercicios'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/day', extra: day),
                  ),
                );
              },
            ),
    );
  }
}

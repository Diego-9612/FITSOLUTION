// lib/features/progress/presentation/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/progress_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DateTime _firstDay = DateTime.utc(2025, 1, 1);
  final DateTime _lastDay = DateTime.utc(2030, 12, 31);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final ProgressRepository _repo;
  late final String _userId;

  List<Map<String, dynamic>> _completions = [];
  Map<String, dynamic>? _streak;
  bool _loading = true;

  static const Map<int, String> _weekdayLabel = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mié',
    4: 'Jue',
    5: 'Vie',
  };

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _repo = ProgressRepository(client);
    _userId = client.auth.currentUser!.id;
    _init();
  }

  Future<void> _init() async {
    await _loadDay(DateTime.now());
    final s = await _repo.getStreak(_userId);
    setState(() {
      _streak = s;
      _selectedDay = DateTime.now();
      _loading = false;
    });
  }

  Future<void> _loadDay(DateTime day) async {
    final c = await _repo.getCompletionsForDate(userId: _userId, date: day);
    setState(() {
      _completions = c;
      _focusedDay = day;
    });
  }

  Future<void> _onDaySelected(DateTime selected, DateTime focused) async {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
      _loading = true;
    });
    await _loadDay(selected);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cur = _streak?['current_streak'] ?? 0;
    final best = _streak?['longest_streak'] ?? 0;
    final count = _completions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                Text('Racha actual: $cur días — Mejor racha: $best días'),
                const SizedBox(height: 8),
                TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  onDaySelected: _onDaySelected,
                  calendarFormat: CalendarFormat.month,
                  availableGestures: AvailableGestures.all,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Completados del día ($count)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: _completions.isEmpty
                      ? const Center(child: Text('No hay registros para este día'))
                      : ListView.builder(
                          itemCount: _completions.length,
                          itemBuilder: (_, i) {
                            final m = _completions[i];
                            final ex = (m['exercise'] as Map?) ?? {};
                            final name = (ex['name'] as String?) ?? 'Ejercicio';
                            final rd = (ex['routine_day'] as Map?) ?? {};
                            final split = (rd['split'] as String?) ?? '';
                            final weekday = (rd['weekday'] as int?) ?? 0;
                            final dayLabel = _weekdayLabel[weekday] ?? '';
                            final extra = (split.isNotEmpty || dayLabel.isNotEmpty)
                                ? ' • $split${dayLabel.isNotEmpty ? ' ($dayLabel)' : ''}'
                                : '';
                            final dateStr = (m['date_ymd'] as String?) ?? '';

                            return ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text(name),
                              subtitle: Text('Fecha: $dateStr$extra'),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
               
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final heightC = TextEditingController();
  final weightC = TextEditingController();
  String? somatotype;
  String? goal;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = Supabase.instance.client;
    final u = c.auth.currentUser!;
    final m = await c.from('profiles').select().eq('id', u.id).maybeSingle();
    if (m != null) {
      heightC.text = (m['height_cm']?.toString() ?? '');
      weightC.text = (m['weight_kg']?.toString() ?? '');
      somatotype = m['somatotype'];
      goal = m['goal'];
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final somatos = ['mesomorfo', 'endomorfo', 'ectomorfo'];
    final goals = ['definicion', 'volumen', 'mantenimiento'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: heightC,
                    decoration: const InputDecoration(labelText: 'Estatura (cm)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightC,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: somatotype,
                    items: somatos
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => somatotype = v),
                    decoration: const InputDecoration(labelText: 'Somatotipo'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: goal,
                    items: goals
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => goal = v),
                    decoration: const InputDecoration(labelText: 'Objetivo'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final c = Supabase.instance.client;
                      final u = c.auth.currentUser!;
                      await c.from('profiles').upsert({
                        'id': u.id,
                        'height_cm': double.tryParse(heightC.text),
                        'weight_kg': double.tryParse(weightC.text),
                        'somatotype': somatotype,
                        'goal': goal,
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado')),
                      );
                    },
                    child: const Text('Guardar'),
                  ),
                  const SizedBox(height: 12),
                  
                  OutlinedButton.icon(
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
                ],
              ),
            ),
    );
  }
}

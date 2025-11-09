import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Correo')),
          const SizedBox(height: 12),
          TextField(controller: passC, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : () async {
              setState(() => loading = true);
              try {
                final repo = AuthRepository(Supabase.instance.client);
                final res = await repo.signIn(emailC.text.trim(), passC.text.trim());
                if (res.user != null) {
                  if (!mounted) return;
                  context.go('/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                setState(() => loading = false);
              }
            },
            child: Text(loading ? 'Cargando...' : 'Entrar'),
          ),
          TextButton(onPressed: () => context.go('/register'), child: const Text('Crear cuenta'))
        ]),
      ),
    );
  }
}

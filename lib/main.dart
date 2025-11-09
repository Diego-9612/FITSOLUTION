import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const FitPplAIApp());
}

class FitPplAIApp extends StatelessWidget {
  const FitPplAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fit PPL AI',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'database/local_database.dart';
import 'services/cache_service.dart';
import 'services/resilient_sync_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await LocalDatabase.init();

  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Cache départements + régions si en ligne
  try { await CacheService.syncReferenceData(); } catch (_) {}

  // Sync automatique au retour en ligne
  ResilientSyncService.enableAutoSync();

  runApp(const ContaApp());
}

class ContaApp extends StatelessWidget {
  const ContaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Conta Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF3ECF8E),
          surface: const Color(0xFF0F1117), // ✅ background → surface
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
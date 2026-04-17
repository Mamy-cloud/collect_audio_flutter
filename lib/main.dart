import 'package:flutter/material.dart';
import 'database/local_database.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase.init();

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
          surface: const Color(0xFF0F1117),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

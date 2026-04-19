import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import './database/create_table/create_table_temoin.dart';
import 'routers/router.dart';
import 'widgets/global/app_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android/iOS → sqflite natif, rien à faire
  // Linux/Windows/macOS → nécessite sqflite_common_ffi
  // Si tu es sur Linux, ajoute sqflite_common_ffi dans pubspec.yaml
  // et décommente les lignes ci-dessous :
  //
  // import 'package:sqflite_common_ffi/sqflite_ffi.dart';
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  try {
    await CreateTableTemoin.init();
  } catch (e, stack) {
    debugPrint('ERREUR INIT DB: $e');
    debugPrint('STACK: $stack');
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                     'Mon Application',
      debugShowCheckedModeBanner: false,
      theme:                     buildAppTheme(),
      routerConfig:              router,
    );
  }
}

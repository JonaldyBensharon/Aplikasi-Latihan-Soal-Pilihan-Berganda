import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(LocalStorageService());
  await controller.initialize();
  runApp(DrillExeApp(controller: controller));
}

class DrillExeApp extends StatelessWidget {
  const DrillExeApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MaterialApp(
          title: 'Drill Exe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(controller: controller),
        ),
      );
}
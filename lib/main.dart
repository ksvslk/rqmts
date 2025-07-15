import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rqmts/core/theme.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';
import 'package:rqmts/features/prioritization/screens/projects_screen.dart';


Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and specify a sub-directory for storage
  await Hive.initFlutter('prequ_data');

  // Register the auto-generated adapters for our models
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(RequirementAdapter());

  // Open the box that will store our projects
  await Hive.openBox<Project>('projects');

  runApp(
    const ProviderScope(
      child: CozyApp(),
    ),
  );
}

class CozyApp extends StatelessWidget {
  const CozyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rqmts',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ProjectsScreen(),
    );
  }
}
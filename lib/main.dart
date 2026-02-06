import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/theme/theme_persistence.dart';
import 'core/theme/theme_provider.dart';

// Layers
import 'data/datasources/in_memory_store.dart';
import 'data/repositories/in_memory_workout_repository.dart';
import 'data/repositories/in_memory_settings_repository.dart';
import 'domain/repositories/workout_repository.dart';
import 'domain/repositories/settings_repository.dart';

// Presentation
import 'presentation/view_models/today_view_model.dart';
import 'presentation/view_models/settings_view_model.dart';
import 'presentation/view_models/history_view_model.dart';
import 'presentation/view_models/progress_view_model.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final store = InMemoryStore();

  // Initialize Repositories
  final workoutRepo = InMemoryWorkoutRepository(store);
  final settingsRepo = InMemorySettingsRepository(store);

  // Load Persisted Theme
  final initialThemeMode = await ThemePersistence.loadThemeMode();

  runApp(
    MultiProvider(
      providers: [
        // Theme Management
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialThemeMode)),

        // Repository Injection
        Provider<WorkoutRepository>.value(value: workoutRepo),
        Provider<SettingsRepository>.value(value: settingsRepo),

        // ViewModel Injection
        ChangeNotifierProvider(create: (_) => SettingsViewModel(settingsRepo)),
        ChangeNotifierProvider(create: (context) => TodayViewModel(workoutRepo, settingsRepo)),
        ChangeNotifierProvider(create: (context) => HistoryViewModel(workoutRepo)),
        ChangeNotifierProvider(create: (context) => ProgressViewModel(workoutRepo)),
      ],
      child: const WorkoutApp(),
    ),
  );
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Workout',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.cupertinoTheme(context),
        home: const MainShell(),
      );
    } else {
      return MaterialApp(
        title: 'Workout',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.materialTheme(context),
        darkTheme: themeProvider.materialTheme(context), // themeData handles both based on brightness
        themeMode: themeProvider.themeMode,
        home: const MainShell(),
      );
    }
  }
}

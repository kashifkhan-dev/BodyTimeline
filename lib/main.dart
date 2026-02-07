import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/theme/theme_persistence.dart';
import 'core/theme/theme_provider.dart';

// Layers
import 'data/datasources/in_memory_store.dart';
import 'data/datasources/sqlite_helper.dart';
import 'data/datasources/sqlite_persistence_service.dart';
import 'data/repositories/in_memory_workout_repository.dart';
import 'data/repositories/in_memory_settings_repository.dart';
import 'domain/repositories/workout_repository.dart';
import 'domain/repositories/settings_repository.dart';

// Presentation
import 'presentation/view_models/today_view_model.dart';
import 'presentation/view_models/settings_view_model.dart';
import 'presentation/view_models/history_view_model.dart';
import 'presentation/view_models/progress_view_model.dart';
import 'presentation/view_models/stats_view_model.dart';
import 'presentation/screens/main_shell.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/in_memory_user_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/view_models/profile_view_model.dart';

// Localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import 'data/repositories/prefs_locale_repository.dart';
import 'domain/repositories/locale_repository.dart';
import 'presentation/view_models/locale_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize storage
  final store = InMemoryStore();
  final sqliteHelper = SqliteHelper();
  final persistenceService = SqlitePersistenceService(sqliteHelper);

  // Initialize Repositories
  final workoutRepo = InMemoryWorkoutRepository(store, persistenceService);
  final settingsRepo = InMemorySettingsRepository(store, prefs);
  final userRepo = InMemoryUserRepository(prefs);
  final localeRepo = PrefsLocaleRepository();

  // Hydrate Data from Persistence Layer
  await settingsRepo.init();
  await workoutRepo.init();

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
        Provider<UserRepository>.value(value: userRepo),
        Provider<LocaleRepository>.value(value: localeRepo),

        // ViewModel Injection
        ChangeNotifierProvider(create: (_) => SettingsViewModel(settingsRepo)),
        ChangeNotifierProvider(create: (context) => TodayViewModel(workoutRepo, settingsRepo)),
        ChangeNotifierProvider(create: (context) => HistoryViewModel(workoutRepo)),
        ChangeNotifierProvider(create: (context) => ProgressViewModel(workoutRepo, settingsRepo)),
        ChangeNotifierProvider(create: (context) => StatsViewModel(workoutRepo)),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(userRepo, workoutRepo, settingsRepo)),
        ChangeNotifierProvider(create: (_) => LocaleViewModel(localeRepo)),
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
    final localeProvider = context.watch<LocaleViewModel>();

    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Workout',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.cupertinoTheme(context),
        locale: localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: const MainShell(),
      );
    } else {
      return MaterialApp(
        title: 'Workout',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.materialTheme(context),
        darkTheme: themeProvider.materialTheme(context),
        themeMode: themeProvider.themeMode,
        locale: localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: const MainShell(),
      );
    }
  }
}

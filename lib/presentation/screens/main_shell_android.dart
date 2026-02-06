import 'package:flutter/material.dart';
import 'today/today_screen.dart';
import 'history/history_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class MainShellAndroid extends StatefulWidget {
  const MainShellAndroid({super.key});

  @override
  State<MainShellAndroid> createState() => _MainShellAndroidState();
}

class _MainShellAndroidState extends State<MainShellAndroid> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodayScreen(),
    const HistoryScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today), label: AppLocalizations.of(context)!.today),
          NavigationDestination(icon: const Icon(Icons.history), label: AppLocalizations.of(context)!.history),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)!.progress),
          NavigationDestination(icon: const Icon(Icons.settings), label: AppLocalizations.of(context)!.settings),
        ],
      ),
    );
  }
}

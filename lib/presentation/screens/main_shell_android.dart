import 'package:flutter/material.dart';
import 'today/today_screen.dart';
import 'history/history_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';

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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

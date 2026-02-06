import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'today/today_screen.dart';
import 'history/history_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';

class MainShellIOS extends StatefulWidget {
  const MainShellIOS({super.key});

  @override
  State<MainShellIOS> createState() => _MainShellIOSState();
}

class _MainShellIOSState extends State<MainShellIOS> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodayScreen(),
    const HistoryScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CNTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                CNTabBarItem(icon: CNSymbol('clock.fill'), label: 'Today'),
                CNTabBarItem(icon: CNSymbol('calendar'), label: 'History'),
                CNTabBarItem(icon: CNSymbol('chart.bar.fill'), label: 'Progress'),
                CNTabBarItem(icon: CNSymbol('gearshape.fill'), label: 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

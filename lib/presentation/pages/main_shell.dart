import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'today_page.dart';
import 'history_page.dart';
import 'progress_page.dart';
import 'settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const TodayPage(), const HistoryPage(), const ProgressPage(), const SettingsPage()];

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

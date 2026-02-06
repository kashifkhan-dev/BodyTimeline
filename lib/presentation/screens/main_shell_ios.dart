import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../view_models/today_view_model.dart';
import 'today/today_screen.dart';
import 'history/history_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

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
          IndexedStack(index: _currentIndex, children: _pages),
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
                // Trigger session reset if switching to Today screen
                if (index == 0) {
                  context.read<TodayViewModel>().onScreenVisible();
                }
              },
              items: [
                CNTabBarItem(icon: const CNSymbol('clock.fill'), label: AppLocalizations.of(context)!.today),
                CNTabBarItem(icon: const CNSymbol('calendar'), label: AppLocalizations.of(context)!.history),
                CNTabBarItem(icon: const CNSymbol('chart.bar.fill'), label: AppLocalizations.of(context)!.progress),
                CNTabBarItem(icon: const CNSymbol('gearshape.fill'), label: AppLocalizations.of(context)!.settings),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

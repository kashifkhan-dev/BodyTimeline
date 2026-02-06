import 'dart:io';
import 'package:flutter/material.dart';
import 'settings_screen_ios.dart';
import 'settings_screen_android.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const SettingsScreenIOS();
    } else {
      return const SettingsScreenAndroid();
    }
  }
}

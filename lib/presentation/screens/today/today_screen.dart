import 'dart:io';
import 'package:flutter/material.dart';
import 'today_screen_ios.dart';
import 'today_screen_android.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const TodayScreenIOS();
    } else {
      return const TodayScreenAndroid();
    }
  }
}

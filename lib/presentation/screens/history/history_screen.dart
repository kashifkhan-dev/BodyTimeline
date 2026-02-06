import 'dart:io';
import 'package:flutter/material.dart';
import 'history_screen_ios.dart';
import 'history_screen_android.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const HistoryScreenIOS();
    } else {
      return const HistoryScreenAndroid();
    }
  }
}

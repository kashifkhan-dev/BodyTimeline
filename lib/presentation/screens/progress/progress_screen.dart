import 'dart:io';
import 'package:flutter/material.dart';
import 'progress_screen_ios.dart';
import 'progress_screen_android.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const ProgressScreenIOS();
    } else {
      return const ProgressScreenAndroid();
    }
  }
}

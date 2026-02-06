import 'dart:io';
import 'package:flutter/material.dart';
import 'language_screen_android.dart';
import 'language_screen_ios.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const LanguageScreenIOS();
    } else {
      return const LanguageScreenAndroid();
    }
  }
}

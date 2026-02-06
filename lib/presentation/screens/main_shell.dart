import 'dart:io';
import 'package:flutter/material.dart';
import 'main_shell_ios.dart';
import 'main_shell_android.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const MainShellIOS();
    } else {
      return const MainShellAndroid();
    }
  }
}

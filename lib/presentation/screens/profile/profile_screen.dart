import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile_screen_ios.dart';
import 'profile_screen_android.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const ProfileScreenIOS();
    } else {
      return const ProfileScreenAndroid();
    }
  }
}

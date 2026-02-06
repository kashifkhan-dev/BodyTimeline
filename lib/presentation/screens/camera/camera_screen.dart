import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../domain/value_objects/zone_type.dart';
import 'camera_screen_ios.dart';
import 'camera_screen_android.dart';

class CameraScreen extends StatelessWidget {
  final ZoneType mode;

  const CameraScreen({super.key, required this.mode});

  static Future<void> show(BuildContext context, ZoneType mode) {
    if (Platform.isIOS) {
      return showCupertinoModalPopup(
        context: context,
        builder: (context) => CameraScreen(mode: mode),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CameraScreen(mode: mode),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CameraScreenIOS(mode: mode);
    } else {
      return CameraScreenAndroid(mode: mode);
    }
  }
}

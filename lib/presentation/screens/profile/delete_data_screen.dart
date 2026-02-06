import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'delete_data_screen_ios.dart';
import 'delete_data_screen_android.dart';

class DeleteDataScreen extends StatelessWidget {
  const DeleteDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const DeleteDataScreenIOS();
    } else {
      return const DeleteDataScreenAndroid();
    }
  }
}

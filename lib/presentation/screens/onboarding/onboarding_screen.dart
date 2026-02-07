import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'onboarding_screen_ios.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const OnboardingScreenIOS();
    } else {
      // Logic for Android can be added later, fallback to iOS for now as per rules
      return const OnboardingScreenIOS();
    }
  }
}

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static const String _reviewRequestedKey = 'has_requested_review';
  final InAppReview _inAppReview = InAppReview.instance;

  /// Attempts to trigger the native in-app review dialog.
  ///
  /// It will only request once per user, gated by a persistent flag in [SharedPreferences].
  /// If the OS rate-limits or refuses, it fails silently as per requirements.
  Future<void> requestReviewIfAppropriate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequested = prefs.getBool(_reviewRequestedKey) ?? false;

      if (hasRequested) {
        debugPrint('ℹ️ Review previously requested. Skipping.');
        return;
      }

      // Check if the native review dialog is available
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        debugPrint('🚀 Triggering native app review prompt...');

        // Save the flag before attempting, ensuring we don't spam even if it fails/refuses
        await prefs.setBool(_reviewRequestedKey, true);

        // Native request - OS decides if it's actually shown
        await _inAppReview.requestReview();
      } else {
        debugPrint('⚠️ Native review API not available on this device/version.');
      }
    } catch (e) {
      // Fail silently as per requirements
      debugPrint('❌ Silent failure in ReviewService: $e');
    }
  }

  /// Resets the review flag (useful for testing, NOT used in production flow)
  Future<void> debugResetReviewFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewRequestedKey);
    debugPrint('🧹 Review flag reset (Debug Only)');
  }
}

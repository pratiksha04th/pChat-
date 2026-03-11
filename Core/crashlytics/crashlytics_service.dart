import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics =
      FirebaseCrashlytics.instance;

  /// Log simple message
  static void log(String message) {
    if (kReleaseMode) {
      _crashlytics.log(message);
    }
  }

  /// Record non-fatal error
  static void recordError(
      dynamic error,
      StackTrace stack, {
        String? reason,
        bool fatal = false,
      }) {
    if (kReleaseMode) {
      _crashlytics.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    }
  }

  /// Attach user info
  static void setUser(String userId) {
    if (kReleaseMode) {
      _crashlytics.setUserIdentifier(userId);
    }
  }

  /// Add structured keys
  static void setKey(String key, dynamic value) {
    if (kReleaseMode) {
      _crashlytics.setCustomKey(key, value);
    }
  }
}
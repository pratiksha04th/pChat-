import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {


  /// LOG EVENT
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  /// RECORD ERROR
  void recordError(dynamic error, StackTrace stack, {String? reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
    );
  }

  /// SET USER CONTEXT
  Future<void> setUserContext(String userId, {String? email}) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);

    if (email != null) {
      FirebaseCrashlytics.instance.setCustomKey("email", email);
    }
  }

  /// SAFE EXECUTION
  Future<T?> runSafe<T>(
      Future<T> Function() task, {
        String? errorReason,
      }) async {
    try {
      return await task();
    } catch (e, stack) {
      recordError(e, stack, reason: errorReason);
      return null;
    }
  }
}
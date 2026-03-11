import 'package:flutter/material.dart';
import 'crashlytics_service.dart';

class GlobalErrorHandler {
  static void init() {
    FlutterError.onError =
        (FlutterErrorDetails details) {
      CrashlyticsService.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        fatal: true,
      );
    };
  }
}
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../Core/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  int? priority = 1;

  /// SHOW SNACKBAR
  void showMessage(String title, String message) {

    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      duration: const Duration(seconds: 3),
    );
  }

  /// REDIRECT LOGIC
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {

    final user = _auth.currentUser;
    final routeName = route.location;

    /// AUTH ROUTES (ALWAYS ALLOWED)
    const authRoutes = [
      AppRoutes.signin,
      AppRoutes.signup,
      AppRoutes.verifyEmail,
      AppRoutes.forgetPassword,
      AppRoutes.splash,
    ];

    if (authRoutes.contains(routeName)) {
      return null;
    }

    /// USER NOT LOGGED IN
    if (user == null) {

      showMessage(
        "Login Required",
        "Please sign in to continue",
      );

      return GetNavConfig.fromRoute(AppRoutes.signin);
    }
    /// USER VALID
    return null;
  }

  /// DEBUG ROUTE CALL
  @override
  GetPage? onPageCalled(GetPage? page) {

    debugPrint("AuthMiddleware -> Opening ${page?.name}");

    return page;
  }
}
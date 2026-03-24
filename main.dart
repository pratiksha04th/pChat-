import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// IMPORT FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pchat/Core/Notification/controller/firebase_messaging_service.dart';
import 'Core/bindings/inital_binding.dart';
import 'Core/crashlytics/crashlytics_service.dart';
import 'Core/crashlytics/error_handler.dart';

import 'Core/routes/app_pages.dart';
import 'Core/routes/app_routes.dart';
import 'Core/services/connectivity_service.dart';
/// FEATURES
import 'Feature/Chat_Screen/controller/chat_controller.dart';
import 'Feature/Home/controller/userController/all_users_controller.dart';
import 'Feature/splash/view/splash_screen.dart';

/// UTILITIES
import 'utilities/App_Colors/App_Colors.dart';

/// HUME AI IMPORTS
import 'Feature/AiAssistant/Features/PermissionScreen/controller/permission_controller.dart';

void main() async {
  await dotenv.load(fileName: "apiKeys.env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  /// Global error handling
  GlobalErrorHandler.init();

  /// Firebase background notifications
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessagingService.init();

  /// PChat Controllers
  Get.put(ConnectivityService(), permanent: true);
  Get.put(CrashlyticsService(), permanent: true);
  Get.put(AllUsersController(), permanent: true);
  Get.put(ChatController(), permanent: true);


  /// Hume AI Controllers
  Get.put(PermissionController(), permanent: true);

  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) {
      CrashlyticsService.recordError(error, stack, fatal: true);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      title: 'pChat',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.splashBgColor,
      ),

      /// app starts with SplashScreen
      home: SplashScreen(),
    );
  }
}

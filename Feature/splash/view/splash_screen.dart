import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Auth/view/SignIn/SignIn.dart';
import 'package:pchat/Feature/Home/view/home_screen.dart';
import '../../../Core/SharedPreferences/session_manager.dart';
import '../../../Core/Notification/controller/firebase_messaging_service.dart';
import '../../../Core/Notification/services/get_server_key.dart';
import '../../../Core/Notification/services/notification_service.dart';
import '../../../utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Images/App_Images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late GetServerKey getServerKey;
    @override
  void initState() {
    super.initState();
    NotificationService.init();
    FirebaseMessagingService.init();
    getToken();
    _checkLogin();
  }
  Future <void> getToken() async{
      getServerKey =  GetServerKey();
      final token = await getServerKey.getServerKeyToken();
      print("ACCESS TOKEN : ${token}");
}
  Future<void> _checkLogin() async {
    final loggedIn = await SessionManager.isLoggedIn();
    await Future.delayed(const Duration(seconds: 3));
    if (loggedIn) {
      Get.offAll(() => HomeScreen(), duration: const Duration(seconds: 1),
    transition: Transition.fade);
  }else {
      Get.off(() => const SignInScreen(),
          duration: const Duration(seconds: 1),
          transition: Transition.fade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor1,
      body: Center(
        child: Image.asset(AppImages.splashScreenImage)
      )
    );
  }
}

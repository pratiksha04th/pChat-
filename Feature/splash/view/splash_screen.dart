import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../Core/routes/app_routes.dart';
import '../../../utilities/App_Images/App_Images.dart';
import '../controller/appController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startApp();
  }

  void startApp() async {

    await Future.delayed(const Duration(seconds: 2));

    final appController =  Get.find<AppController>();
    appController.handleAppStart();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              AppImages.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          /// CENTER LOGO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  AppImages.logo,
                  height: 280,
                ),


              ],
            ),
          )
        ],
      ),
    );
  }
}
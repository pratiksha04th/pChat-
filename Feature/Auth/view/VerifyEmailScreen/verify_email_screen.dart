import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../controller/auth_controlller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      if (user != null && user.emailVerified) {
        timer.cancel();

        final controller = Get.find<AuthController>();
        controller.checkVerificationAndProfile();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
          ),

          /// Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Logo
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 1.7,
                        child: Image.asset(AppImages.logo),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Verify Email",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Please verify your email to continue",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 35),

                    /// Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read,
                            size: 80,
                            color: Colors.blue,
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Verification email sent.\nPlease check your inbox.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 25),

                          const CircularProgressIndicator(),

                          const SizedBox(height: 15),

                          const Text(
                            "Waiting for email verification...",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),

                          const SizedBox(height: 20),

                          /// Resend button
                          TextButton(
                            onPressed: () async {
                              try {
                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  Get.snackbar(
                                    "Error",
                                    "User not found",
                                    backgroundColor: Colors.red.shade100,
                                  );
                                  return;
                                }

                                await user.sendEmailVerification();

                                /// SUCCESS SNACKBAR
                                Get.snackbar(
                                  "Email Sent",
                                  "Verification email has been sent successfully",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade100,
                                );
                              } on FirebaseAuthException catch (e) {
                                /// ERROR SNACKBAR
                                String message = "Failed to send email";

                                if (e.code == "too-many-requests") {
                                  message =
                                      "Too many requests. Please wait and try again.";
                                }

                                Get.snackbar(
                                  "Error",
                                  message,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  "Error",
                                  "Something went wrong",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                );
                              }
                            },
                            child: Text(
                              "Resend Email",
                              style: TextStyle(
                                color: AppColors.themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

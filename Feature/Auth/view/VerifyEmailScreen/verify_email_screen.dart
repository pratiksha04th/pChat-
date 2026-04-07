import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../../utilities/App_Strings/app_strings.dart';
import '../../controller/auth_controlller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? timer;
  late String email;
  final TextEditingController editEmailController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    email = Get.arguments ?? FirebaseAuth.instance.currentUser?.email ?? "";

    editEmailController.text = email;
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

  /// re_authenticate email
  Future<void> reAuthenticateUser(String password) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(cred);
  }

  /// email update or edit
  Future<void> updateEmail() async {
    final newEmail = editEmailController.text.trim();

    if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
      Get.snackbar(
        AppStrings.invalidEmail,
        AppStrings.enterValidEmail,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await user.verifyBeforeUpdateEmail(newEmail);

      setState(() {
        email = newEmail;
        isEditing = false;
      });

      Get.snackbar(
        "Verification Sent",
        "Check your new email to verify",
        backgroundColor: Colors.green.shade100,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        /// SHOW PASSWORD DIALOG
        final password = await _showPasswordDialog();

        if (password == null) return;

        try {
          await reAuthenticateUser(password);

          /// TRY AGAIN AFTER RE-AUTH
          await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(
            newEmail,
          );

          setState(() {
            email = newEmail;
            isEditing = false;
          });

          Get.snackbar(
            "Verification Sent",
            "Check your new email",
            backgroundColor: Colors.green.shade100,
          );
        } catch (e) {
          Get.snackbar(
            AppStrings.error,
            "Re-authentication failed",
            backgroundColor: Colors.red.shade100,
          );
        }

        return;
      }

      Get.snackbar(
        AppStrings.error,
        "Failed to update email",
        backgroundColor: Colors.red.shade100,
      );
    }
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
                      AppStrings.verifyEmailTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      AppStrings.verifyEmailSubtitle,
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

                          if (!isEditing) ...[
                            Text(
                              "We've sent a verification link to",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.themeColor,
                              ),
                            ),

                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                  editEmailController.text = email;
                                });
                              },
                              child: const Text(AppStrings.editEmail),
                            ),
                          ],
                          if (isEditing) ...[
                            TextField(
                              controller: editEmailController,
                              decoration: InputDecoration(
                                hintText: "Enter new email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                    });
                                  },
                                  child: const Text(AppStrings.cancel),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.themeColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    print(AppStrings.updateEmail);
                                    updateEmail();
                                  },
                                  child: const Text(AppStrings.update),
                                ),
                              ],
                            ),
                          ],

                          if (!isEditing)
                            const Text(
                              "Please check your inbox and verify your email to continue.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                          const SizedBox(height: 25),

                          const Text(
                            AppStrings.waitingVerification,
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
                                    AppStrings.error,
                                    AppStrings.userNotFound,
                                    backgroundColor: Colors.red.shade100,
                                  );
                                  return;
                                }

                                await user.sendEmailVerification();

                                /// SUCCESS SNACKBAR
                                Get.snackbar(
                                  AppStrings.emailSent,
                                  AppStrings.emailSentSuccess,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade100,
                                );
                              } on FirebaseAuthException catch (e) {
                                /// ERROR SNACKBAR
                                String message = AppStrings.failedToSendEmail;

                                if (e.code == "too-many-requests") {
                                  message = AppStrings.tooManyRequests;
                                }

                                Get.snackbar(
                                  AppStrings.error,
                                  message,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  AppStrings.error,
                                  AppStrings.somethingWentWrong,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                );
                              }
                            },
                            child: Text(
                              AppStrings.resendEmail,
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

  Future<String?> _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();

    String? result;

    await Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.reAuth),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.enterPassword),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: AppStrings.password),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              result = passwordController.text.trim();
              Get.back();
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    return result;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/routes/app_routes.dart';
import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';

import '../../../../utilities/App_Strings/app_strings.dart';
import '../../controller/auth_controlller.dart';
class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              AppImages.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [

                          const SizedBox(height: 50),

                          /// LOGO
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

                          const SizedBox(height: 20),

                          const Text(
                            AppStrings.welcomeBack,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            AppStrings.signInSubtitle,
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 30),

                          /// CARD
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
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

                                  /// EMAIL
                                  TextFormField(
                                    controller: authController.emailController,
                                    validator: authController.validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: AppInputDecoration.build(
                                      hint: AppStrings.emailHint,
                                      label: AppStrings.email,
                                      icon: Icons.email_outlined,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  /// PASSWORD
                                  Obx(() => TextFormField(
                                    controller: authController.passwordController,
                                    validator: authController.validatePassword,
                                    obscureText:
                                    authController.obscurePassword.value,
                                    decoration: AppInputDecoration.build(
                                      hint: AppStrings.passwordHint,
                                      label: AppStrings.password,
                                      icon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          authController.obscurePassword.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          authController.obscurePassword
                                              .toggle();
                                        },
                                      ),
                                    ),
                                  )),

                                  /// FORGOT PASSWORD
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Get.toNamed(AppRoutes.forgetPassword);
                                      },
                                      child: Text(
                                        AppStrings.forgotPasswordQ,
                                        style: TextStyle(
                                          color: AppColors.themeColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  /// SIGN IN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: authController.isLoading.value
                                          ? null
                                          : () {
                                        authController.signIn(formKey);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        AppColors.themeColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: Obx (() => authController.isLoading.value
                                          ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : const Text(
                                        AppStrings.signIn,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )),

                                  const SizedBox(height: 15),

                                  /// OR DIVIDER
                                  Row(
                                    children: const [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(AppStrings.or),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  /// SIGN UP
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(AppStrings.dontHaveAccount),
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed(AppRoutes.signup);
                                        },
                                        child: Text(
                                          AppStrings.signUp,
                                          style: TextStyle(
                                            color: AppColors.themeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
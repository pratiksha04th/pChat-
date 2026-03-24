//<----- SIGNUP SCREEN (create new account) ----->

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';
import '../../../../Core/routes/app_routes.dart';
import '../../controller/auth_controlller.dart';
import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find<AuthController>();

  // used to validate the form
  final _formkey = GlobalKey<FormState>();

  //<---  UI ----->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
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
                      key: _formkey,
                      child: Column(
                        children: [
                          const SizedBox(height: 50),

                          // Logo
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
                              child: Image.asset(
                                AppImages.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Join us to get started",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 30),

                          // CARD CONTAINER
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
                                    decoration: AppInputDecoration.build(
                                      hint: 'example@gmail.com',
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  /// USERNAME
                                  TextFormField(
                                    controller:
                                        authController.usernameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Username is required";
                                      }
                                      return null;
                                    },
                                    decoration: AppInputDecoration.build(
                                      label: "Username",
                                      hint: "username",
                                      icon: Icons.person_outline,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  /// PASSWORD
                                  /// PASSWORD
                                  Obx(
                                    () => TextFormField(
                                      controller:
                                          authController.passwordController,
                                      validator:
                                          authController.validatePassword,
                                      obscureText:
                                          authController.obscurePassword.value,
                                      onChanged:
                                          authController.checkPasswordStrength,
                                      decoration: AppInputDecoration.build(
                                        hint: '******',
                                        label: 'Password',
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            authController.obscurePassword.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => authController
                                              .obscurePassword
                                              .toggle(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// PASSWORD STRENGTH BAR
                                  Obx(() {
                                    if (!authController
                                        .isPasswordTyping
                                        .value) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: _buildSegmentedStrengthBar(
                                        authController.passwordScore,
                                        authController.passwordLabel,
                                      ),
                                    );
                                  }),

                                  /// PASSWORD REQUIREMENTS
                                  Obx(() {
                                    if (!authController
                                        .isPasswordTyping
                                        .value) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _buildRequirement(
                                            "1 special character",
                                            authController.hasSpecialChar.value,
                                          ),
                                          _buildRequirement(
                                            "1 number",
                                            authController.hasNumber.value,
                                          ),
                                          _buildRequirement(
                                            "6+ characters",
                                            authController.hasMinLength.value,
                                          ),
                                          _buildRequirement(
                                            "1 capital letter",
                                            authController.hasUppercase.value,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 20),

                                  /// TERMS CHECKBOX
                                  Row(
                                    children: [
                                      Checkbox(value: true, onChanged: (v) {}),
                                      const Expanded(
                                        child: Text(
                                          "I agree to Terms & Privacy Policy",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  /// CREATE ACCOUNT BUTTON
                                  SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: () => authController.isLoading.value
                                          ? null
                                            : authController.signUp(_formkey),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.themeColor,
                                          elevation: 6,
                                          shadowColor: AppColors.themeColor
                                              .withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: Obx(
                                          () => authController.isLoading.value
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const Text(
                                                  "Create Account",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),

                                  /// ---------- or ----------
                                  const SizedBox(height: 15),

                                  Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text("or"),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  /// SIGN IN TEXT
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Already have an account? "),
                                      GestureDetector(
                                        onTap: () {
                                          Get.offAllNamed(AppRoutes.signin);
                                        },
                                        child: Text(
                                          "Sign In",
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

                          const SizedBox(height: 30),
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

  //<---- Requirement for strong password ----->
  Widget _buildRequirement(String text, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: isMet ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMet ? Colors.blue.shade100 : Colors.grey.shade400,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.cancel,
            size: 14,
            color: isMet ? AppColors.themeColor : Colors.grey,
          ),
          const SizedBox(width: 1),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppColors.themeColor : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  //<--- Segmented Strength Bar ----->
  Widget _buildSegmentedStrengthBar(int score, String label) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index < score
                        ? AppColors.themeColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.themeColor,
          ),
        ),
      ],
    );
  }
}

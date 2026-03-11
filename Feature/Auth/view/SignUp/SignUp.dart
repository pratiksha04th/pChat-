//<----- SIGNUP SCREEN (create new account) ----->

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';
import '../../controller/auth_controlller.dart';
import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../SignIn/SignIn.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.put(AuthController());

  // used to validate the form
  final _formkey = GlobalKey<FormState>();

  //<------- SIGNUP FUNCTION ------->

  //<---  UI ----->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              SizedBox(height: 150),
              Container(
                alignment: Alignment.center,
                height: 100,
                width: 100,
                child: Image.asset(AppImages.logo),
              ),
              Text(
                'Welcome',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text(
                'Please Sign Up to continue',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 30),
              //<--- TEXT Form FIELD email ----->
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: authController.emailController, // controller
                  validator: authController.validateEmail, // validator
                  decoration: AppInputDecoration.build(
                    // decoration from    ---   Widget/textField/input_decoration.dart
                    hint: 'example@gmail.com',
                    label: 'Email',
                    icon: Icons.email,
                  ),
                ),
              ),
              SizedBox(height: 10),
              //<--- TEXT Form FIELD username ----->
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: authController.usernameController,
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
              ),

              SizedBox(height: 10),
              //<--- TEXT Form FIELD password ----->
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: authController.passwordController, // controller
                    validator: authController.validatePassword, // validator
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: authController.obscurePassword.value,
                    onChanged: authController.checkPasswordStrength,
                    decoration: AppInputDecoration.build(
                      // decoration from    ---   Widget/textField/input_decoration.dart
                      hint: '******',
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            authController.obscurePassword.toggle(),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (!authController.isPasswordTyping.value) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: _buildSegmentedStrengthBar(
                    authController.passwordScore,
                    authController.passwordLabel,
                  ),
                );
              }),

              //<--- requirements for strong password ----->
              Obx(() {
                if (!authController.isPasswordTyping.value) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
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

              SizedBox(height: 40),
              //<----- if already have an account, please sign in ----->
              InkWell(
                onTap: () {
                  Get.offAll(() => const SignInScreen());
                },
                child: Text("if already have an account, please sign in",
                  style: TextStyle(
                    color: AppColors.redColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.redColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              //<---- SIGNUP BUTTON ----->
              ElevatedButton(
                onPressed: () => authController.signUp(_formkey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Obx(
                  () => authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Account",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
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

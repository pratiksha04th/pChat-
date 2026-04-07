import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';
import '../../../../utilities/App_Strings/app_strings.dart';
import '../../controller/auth_controlller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: GestureDetector(

        /// dismiss keyboard
        onTap: () => FocusScope.of(context).unfocus(),

        child: Stack(
          children: [
            /// BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
            ),

            /// CONTENT
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 50),

                            /// LOGO
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
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

                            /// TITLE
                            const Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              AppStrings.forgotPasswordSubtitle,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 40),

                            /// CARD CONTAINER
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
                                    /// EMAIL FIELD
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

                                    const SizedBox(height: 20),

                                    /// RESET BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                          onPressed:
                                              authController.isLoading.value
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    authController
                                                        .sendPasswordResetEmail();
                                                  }
                                                },
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
                                          child: Obx( () => authController.isLoading.value
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const Text(
                                                  AppStrings.sendResetEmail,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    /// BACK TO SIGN IN
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(AppStrings.rememberPassword),

                                        GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Text(
                                            AppStrings.signIn,
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
      ),
    );
  }
}

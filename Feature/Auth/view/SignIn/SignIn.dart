//<----- SIGNIn SCREEN (if already have an account) ----->

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Home/controller/userController/all_users_controller.dart';
import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Home/view/home_screen.dart';
import '../SignUp/SignUp.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // used to validate the form
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController =
      TextEditingController(); // email controller
  final TextEditingController passwordController =
      TextEditingController(); // password controller

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool obscurePassword = true;
  String? passwordError;

  //<-- validate email --->
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@')) {
      return "Enter a valid email";
    }
    return null;
  }

  //<--- validate password ---->

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  //<------- SIGNIN FUNCTION ------->
  Future<void> _signIn() async {
    if (!_formkey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // LOGIN
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();

        Get.snackbar(
          "Email not verified",
          "Please verify your email before logging in.",
          backgroundColor: Colors.orange.shade100,
        );

        setState(() => isLoading = false);
        return;
      }

      final uid = user!.uid;

      // CHECK USER IN DATABASE
      final ref = FirebaseDatabase.instance.ref("users/$uid");
      final snap = await ref.get();

      // IF NOT EXISTS -> CREATE
      if (!snap.exists) {
        await ref.set({
          "uid": uid,
          "email": emailController.text.trim(),
          "username": emailController.text.split("@")[0], // default name
          "createdAt": DateTime.now().millisecondsSinceEpoch,
        });
      }

      // LOAD USER DATA
      final userCtrl = Get.find<AllUsersController>();
      await userCtrl.loadCurrentUser();

      // GO TO HOME
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }

      Get.snackbar("Error", message, backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => isLoading = false);
    }
  }

  //< ---- real-time validation check ----->
  void _checkPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = "Password is required";
      } else if (value.length < 6) {
        passwordError = "Password must be at least 6 characters";
      } else {
        passwordError = null;
      }
    });
  }

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
                'Please Sign In to continue ',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 30),
              //<--- TEXT Form FIELD email ----->
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: emailController, // controller
                  validator: _validateEmail, // validator
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppInputDecoration.build(
                    // decoration from    ---   Widget/textField/input_decoration.dart
                    hint: 'example@gmail.com',
                    label: 'Email',
                    icon: Icons.email,
                  ),
                ),
              ),
              SizedBox(height: 10),
              //<--- TEXT Form FIELD password ----->
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: passwordController, // controller
                  validator: _validatePassword,
                  obscureText: obscurePassword, // hide password
                  onChanged: _checkPassword, // real_time validation
                  keyboardType: TextInputType.visiblePassword,
                  decoration: AppInputDecoration.build(
                    // decoration from    ---   Widget/textField/input_decoration.dart
                    hint: '******',
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              //<----- if you don't have an account, please sign up ----->
              InkWell(
                onTap: () {
                  Get.to(() => const SignUpScreen());
                },
                child: Text(
                  "if you don't have an account, please sign up",
                  style: TextStyle(
                    color: AppColors.redColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.redColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              //<---- SIGNIN BUTTON ----->
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : _signIn, // on press call signUp function
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // resend email
              TextButton(
                onPressed: () async {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await user.sendEmailVerification();

                      Get.snackbar(
                        "Email Sent",
                        "Verification email sent again",
                      );
                    } else {
                      Get.snackbar(
                        "Login Required",
                        "Please login first to resend verification",
                      );
                    }
                  } catch (e) {
                    Get.snackbar("Error", e.toString());
                  }
                },
                child: Text("Resend verification email"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

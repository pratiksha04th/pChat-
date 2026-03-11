import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/SignIn/SignIn.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  // database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  // UI state
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isPasswordTyping = false.obs;


  // Password rules
  var hasUppercase = false.obs;
  var hasLowercase = false.obs;
  var hasNumber = false.obs;
  var hasSpecialChar = false.obs;
  var hasMinLength = false.obs;

  static const int totalSegments = 4;

  // ------------ PASSWORD LOGIC ------------

  void checkPasswordStrength(String password) {
    isPasswordTyping.value = password.isNotEmpty;
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasLowercase.value = RegExp(r'[a-z]').hasMatch(password);
    hasNumber.value = RegExp(r'\d').hasMatch(password);
    hasSpecialChar.value = RegExp(r'[!@#\$&*~]').hasMatch(password);
    hasMinLength.value = password.length >= 6;
  }

  int get passwordScore {
    int score = 0;
    if (hasMinLength.value) score++;
    if (hasNumber.value) score++;
    if (hasUppercase.value) score++;
    if (hasSpecialChar.value) score++;
    return score.clamp(0, totalSegments);
  }

  String get passwordLabel {
    if (passwordScore <= 1) return "Weak";
    if (passwordScore == 2) return "Okay";
    return "Good";
  }

  // ------------ VALIDATION ---------

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "At least 6 characters required";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Add uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Add lowercase letter";
    if (!RegExp(r'\d').hasMatch(value)) return "Add a number";
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return "Add special character";
    }
    return null;
  }


  // ------------ AUTH -------------

  Future<void> signUp(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {

        await FirebaseDatabase.instance.ref("users/${user.uid}").set({
          "uid": user.uid,
          "email": emailController.text.trim(),
          "username": usernameController.text.trim(),
          "createdAt": ServerValue.timestamp,
        });

        // SEND VERIFICATION EMAIL
        await user.sendEmailVerification();
        print("Verification email sent");

        Get.snackbar(
          "Verify Email",
          "Verification email sent. Please verify before login.",
          backgroundColor: Colors.green.shade100,
        );

        // SIGN OUT USER
        await _auth.signOut();

        // GO TO SIGNIN
        Get.off(() => const SignInScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Email already exists",
          "Please sign in or use a different email",
          backgroundColor: Colors.red.shade100,
        );
      } else if (e.code == 'invalid-email') {
        Get.snackbar("Invalid email", "Enter a valid email");
      } else if (e.code == 'weak-password') {
        Get.snackbar("Weak password", "Choose a stronger password");
      } else {
        Get.snackbar("Signup failed", e.message ?? "Something went wrong");
      }
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

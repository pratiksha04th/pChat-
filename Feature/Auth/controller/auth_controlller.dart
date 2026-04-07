import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Model/app_user.dart';
import '../../../Core/routes/app_routes.dart';

class AuthController extends GetxController {

  /// ---------------- FIREBASE ----------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  /// ---------------- TEXT CONTROLLERS ----------------
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  /// ---------------- UI STATE ----------------
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final gender = "".obs;

  /// ---------------- PASSWORD STATE ----------------
  final hasUppercase = false.obs;
  final hasLowercase = false.obs;
  final hasNumber = false.obs;
  final hasSpecialChar = false.obs;
  final hasMinLength = false.obs;

  static const int totalSegments = 4;
  final isPasswordTyping = false.obs;

  /// ---------------- COMMON SNACKBAR ----------------
  void _showMessage(String title, String message, {Color? color}) {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color ?? Colors.blue.shade100,
    );
  }

  /// ---------------- PASSWORD CHECK ----------------
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
    return "Strong";
  }

  /// ---------------- VALIDATION ----------------
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    if (!GetUtils.isEmail(value)) return "Enter a valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "At least 6 characters required";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Add uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Add lowercase letter";
    if (!RegExp(r'\d').hasMatch(value)) return "Add a number";
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return "Add special character";
    return null;
  }

  /// ---------------- SIGN UP ----------------
  Future<void> signUp(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception("User creation failed");

      final newUser = AppUser(
        uid: user.uid,
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        firstName: "",
        lastName: "",
        gender: "",
        dob: "",
        profileCompleted: false,
        profileImage: "",
        fcmToken: "",
        crashlyticsUserId: "",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        isOnline: true,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
        lat: 0.0,
        lng: 0.0,
      );

      await _dbRef.child(user.uid).set(newUser.toMap());

      await user.sendEmailVerification();

      _showMessage(
        "Verify Email",
        "Verification email sent. Please verify before login.",
        color: Colors.green.shade100,
      );

      final email = emailController.text.trim();

      clearAuthFields();

      Get.offAllNamed(
        AppRoutes.verifyEmail,
        arguments: email,
      );

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showMessage("Error", e.toString(), color: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- SIGN IN ----------------
  Future<void> signIn(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception("Login failed");

      await user.reload();

      if (!_auth.currentUser!.emailVerified) {
        await _auth.signOut();

        _showMessage(
          "Email not verified",
          "Please verify your email first.",
          color: Colors.orange.shade100,
        );
        return;
      }

      clearAuthFields();

      /// IMPORTANT: central flow
      await checkVerificationAndProfile();

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showMessage("Error", e.toString(), color: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- RESET PASSWORD ----------------
  Future<void> sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Email Required", "Please enter your email",
          color: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;

      await _auth.sendPasswordResetEmail(email: email);

      _showMessage(
        "Reset Email Sent",
        "Check your inbox",
        color: Colors.green.shade100,
      );

      emailController.clear();

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- SAVE PROFILE ----------------
  Future<void> saveProfile(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    if (gender.value.isEmpty) {
      _showMessage("Gender Required", "Please select gender",
          color: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;

      final uid = _auth.currentUser!.uid;

      await _dbRef.child(uid).update({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "dob": dobController.text.trim(),
        "gender": gender.value,
        "profileCompleted": true,
        "lastUpdated": ServerValue.timestamp,
      });

      _showMessage(
        "Profile Created",
        "Your profile is complete",
        color: Colors.green.shade100,
      );

      clearProfileFields();

      /// FIXED FLOW
      Get.offAllNamed(AppRoutes.mainScreen);

    } catch (e) {
      _showMessage("Error", "Failed to save profile",
          color: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- CENTRAL FLOW ----------------
  Future<void> checkVerificationAndProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.reload();

    if (!user.emailVerified) {
      Get.offAllNamed(AppRoutes.verifyEmail);
      return;
    }

    final snapshot = await _dbRef.child(user.uid).get();

    if (snapshot.exists) {
      final appUser = AppUser.fromMap(
        snapshot.key!,
        Map<String, dynamic>.from(snapshot.value as Map),
      );

      if (appUser.profileCompleted) {
        Get.offAllNamed(AppRoutes.mainScreen);
      } else {
        Get.offAllNamed(AppRoutes.createProfile,
            arguments: appUser.username);
      }
    } else {
      Get.offAllNamed(AppRoutes.createProfile);
    }
  }


  /// ---------------- ERROR HANDLER ----------------
  void _handleAuthError(FirebaseAuthException e) {
    String message = "Something went wrong";

    switch (e.code) {
      case 'email-already-in-use':
        message = "Email already exists";
        break;
      case 'invalid-email':
        message = "Invalid email";
        break;
      case 'weak-password':
        message = "Weak password";
        break;
      case 'user-not-found':
        message = "No account found";
        break;
      case 'wrong-password':
        message = "Incorrect password";
        break;
    }

    _showMessage("Error", message, color: Colors.red.shade100);
  }

  /// PICKDOB
  Future<void> pickDOB(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (picked != null) {
      dobController.text =
      "${picked.day}-${picked.month}-${picked.year}";
    }
  }
  // for connectivity status

  void _setOnline(bool status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseDatabase.instance.ref("users/${user.uid}").update({
      "isOnline": status,
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// ---------------- HELPERS ----------------
  void clearAuthFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    usernameController.clear();
  }

  void clearProfileFields() {
    firstNameController.clear();
    lastNameController.clear();
    dobController.clear();
    gender.value = "";
  }
}
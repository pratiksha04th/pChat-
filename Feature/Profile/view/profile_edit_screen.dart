import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../Core/routes/app_routes.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {

  final DatabaseReference db = FirebaseDatabase.instance.ref("users");

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;

  bool isEmailVerified = false;
  bool isVerifying = false;
  Timer? verifyTimer;

  @override
  void initState() {
    super.initState();
    loadUserData();
    refreshUser();
  }

  /// LOAD USER DATA
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await db.child(user.uid).get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        usernameController.text = data["username"] ?? "";
        emailController.text = data["email"] ?? "";

        firstNameController.text = data["firstName"] ?? "";
        lastNameController.text = data["lastName"] ?? "";
        dobController.text = data["dob"] ?? "";
        genderController.text = data["gender"] ?? "";

        isLoading = false;
      });
    }
  }

  /// UPDATE PROFILE
  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      /// Update Email (Auth)
      if (emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text.trim());
      }

      /// Update Database
      await db.child(user.uid).update({
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "dob": dobController.text.trim(),
        "gender": genderController.text.trim(),
      });

      Get.snackbar("Success", "Profile updated");

      Get.back();

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(AppRoutes.signin);
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              AppImages.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Get.back(),
                        ),
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        /// LOGOUT
                        TextButton(
                          onPressed: logout,
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// AVATAR
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.themeColor,
                    child: Text(
                      usernameController.text.isNotEmpty
                          ? usernameController.text[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// FORM CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        children: [

                          buildField("Username", Icons.alternate_email, usernameController),

                          const SizedBox(height: 15),

                          /// EMAIL + VERIFY
                          Row(
                            children: [
                              Expanded(
                                child: buildField("Email", Icons.email, emailController),
                              ),

                              const SizedBox(width: 10),

                              TextButton(
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;

                                  if (user == null) return;

                                  /// Already verified
                                  if (isEmailVerified) {
                                    Get.snackbar(
                                      "Verified",
                                      "Your email is already verified",
                                      backgroundColor: Colors.green.shade100,
                                    );
                                    return;
                                  }

                                  try {
                                    /// Send verification email
                                    await user.sendEmailVerification();

                                    Get.snackbar(
                                      "Email Sent",
                                      "Check your email to verify your account",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green.shade100,
                                    );

                                    /// Start loader + checking
                                    setState(() => isVerifying = true);

                                    verifyTimer?.cancel();
                                    verifyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
                                      await refreshUser();

                                      if (isEmailVerified) {
                                        timer.cancel();

                                        setState(() => isVerifying = false);

                                        Get.snackbar(
                                          "Success",
                                          "Email verified successfully",
                                          backgroundColor: Colors.green.shade100,
                                        );
                                      }
                                    });

                                  } on FirebaseAuthException catch (e) {
                                    String msg = "Failed to send email";

                                    if (e.code == "too-many-requests") {
                                      msg = "Too many requests. Try again later.";
                                    }

                                    Get.snackbar(
                                      "Error",
                                      msg,
                                      backgroundColor: Colors.red.shade100,
                                    );
                                  }
                                },

                                child: isVerifying
                                    ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : Text(
                                  isEmailVerified ? "Verified" : "Verify",
                                  style: TextStyle(
                                    color: isEmailVerified
                                        ? Colors.blue
                                        : AppColors.themeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 15),

                          buildField("First Name", Icons.person_outline, firstNameController),

                          const SizedBox(height: 15),

                          buildField("Last Name", Icons.person, lastNameController),

                          const SizedBox(height: 15),

                          buildField("Date of Birth", Icons.cake, dobController),

                          const SizedBox(height: 15),

                          buildField("Gender", Icons.people, genderController),

                          const SizedBox(height: 25),

                          /// UPDATE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: updateProfile,
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// TEXT FIELD
  Widget buildField(
      String label,
      IconData icon,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  /// refresh user
  Future<void> refreshUser() async {
    final user = FirebaseAuth.instance.currentUser;

    await user?.reload();

    final refreshedUser = FirebaseAuth.instance.currentUser;

    setState(() {
      isEmailVerified = refreshedUser?.emailVerified ?? false;
    });
  }
}
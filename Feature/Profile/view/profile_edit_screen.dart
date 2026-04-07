import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Home/controller/userController/all_users_controller.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../Core/routes/app_routes.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../../Auth/controller/auth_controlller.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final DatabaseReference db = FirebaseDatabase.instance.ref("users");
  final AllUsersController userController = Get.find();
  final AuthController authController = Get.find();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;
  bool isUpdating = false;

  bool isEmailVerified = false;
  bool isVerifying = false;
  Timer? verifyTimer;
  String? pendingEmail;

  @override
  void initState() {
    super.initState();
    loadUserData();
    syncEmailWithDatabase();
  }

  Future<void> syncEmailWithDatabase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await user.reload();

    final latestEmail = user.email;

    if (latestEmail == null) return;

    await FirebaseDatabase.instance
        .ref("users/${user.uid}")
        .update({
      "email": latestEmail,
      "emailVerified": user.emailVerified,
    });
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

  Future<bool> isEmailAlreadyUsed(String email) async {
    final snapshot = await db.get();

    if (!snapshot.exists) return false;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    for (var user in data.values) {
      if (user["email"] == email) {
        return true;
      }
    }

    return false;
  }

  Future<void> reAuthenticateUser(String password) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    String? result;

    await Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.themeColor,
                  size: 28,
                ),
              ),

              const SizedBox(height: 15),

              /// TITLE
              const Text(
                "Re-authenticate",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              const Text(
                "Enter your password to continue",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              /// PASSWORD FIELD
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// RESET PASSWORD BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user?.email == null) {
                      Get.snackbar(
                        "Error",
                        "No email found",
                        backgroundColor: Colors.red.shade100,
                      );
                      return;
                    }

                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: user!.email!);

                    final email = user!.email!;

                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);

                    Get.snackbar(
                      "Reset Email Sent",
                      "Password reset link sent to\n$email",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green.shade100,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  child: const Text(
                    "Reset Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// CONFIRM
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        result = controller.text.trim();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return result;
  }

  /// UPDATE PROFILE
  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    /// BASIC VALIDATION
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.emptyUsernameEmail,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    try {
      setState(() => isUpdating = true);

      userController.currentUserData.value = userController
          .currentUserData
          .value
          ?.copyWith(
            username: usernameController.text.trim(),
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            gender: genderController.text.trim(),
            dob: dobController.text.trim(),
          );

      if (emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text.trim());

        /// RESET VERIFICATION STATUS IN DB
        await db.child(user.uid).update({"emailVerified": false});

        setState(() {
          isEmailVerified = false;
        });

        Get.snackbar(
          AppStrings.verifyEmail,
          AppStrings.checkEmail,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
        );
      }

      await db.child(user.uid).update({
        "username": usernameController.text.trim(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "dob": dobController.text.trim(),
        "gender": genderController.text.trim(),
        "lastUpdated": ServerValue.timestamp,
      });

      Get.snackbar(
        AppStrings.success,
        AppStrings.profileUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.themeColor.withOpacity(0.9),
                    AppColors.themeColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          const Text(
                            AppStrings.editProfile,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const Spacer(),

                          /// LOGOUT
                          TextButton(
                            onPressed: showLogoutDialog,
                            child: const Text(
                              AppStrings.logout,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// AVATAR
                    Obx(() {
                      final user = userController.currentUserData.value;
                      final username =
                          user?.username ?? AppStrings.defaultAvatar;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.themeColor,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : AppStrings.defaultAvatar,
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (isUpdating)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),

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
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            buildField(
                              AppStrings.username,
                              Icons.alternate_email,
                              usernameController,
                            ),

                            const SizedBox(height: 15),

                            /// EMAIL + VERIFY
                            Row(
                              children: [
                                Expanded(
                                  child: buildField(
                                    AppStrings.email,
                                    Icons.email,
                                    emailController,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                TextButton(
                                  onPressed: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user == null) return;

                                    final newEmail = emailController.text
                                        .trim();
                                    pendingEmail = newEmail;

                                    /// VALIDATE EMAIL
                                    if (newEmail.isEmpty ||
                                        !GetUtils.isEmail(newEmail)) {
                                      Get.snackbar(
                                        AppStrings.invalidEmail,
                                        AppStrings.enterValidEmail,
                                        backgroundColor: Colors.red.shade100,
                                      );
                                      return;
                                    }

                                    /// CHECK IF EMAIL ALREADY EXISTS
                                    final exists = await isEmailAlreadyUsed(
                                      newEmail,
                                    );

                                    if (exists) {
                                      Get.snackbar(
                                        AppStrings.emailExists,
                                        AppStrings.emailAlreadyRegistered,
                                        backgroundColor: Colors.red.shade100,
                                      );
                                      return;
                                    }

                                    try {
                                      /// SEND VERIFICATION TO NEW EMAIL
                                      await user.verifyBeforeUpdateEmail(
                                        newEmail,
                                      );

                                      /// RESET DB STATUS
                                      await db.child(user.uid).update({
                                        "emailVerified": false,
                                      });

                                      setState(() {
                                        isEmailVerified = false;
                                        isVerifying = true;
                                      });

                                      Get.snackbar(
                                        AppStrings.emailSent,
                                        "${AppStrings.verificationSendTo} $newEmail",
                                        backgroundColor: Colors.green.shade100,
                                      );

                                      /// START TIMER CHECK
                                      verifyTimer?.cancel();
                                      verifyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {

                                        /// ALWAYS FETCH FRESH USER
                                        final user = FirebaseAuth.instance.currentUser;

                                        if (user == null) return;

                                        await user.reload();

                                        final updatedUser = FirebaseAuth.instance.currentUser;

                                        /// RELIABLE CHECK
                                        if (pendingEmail != null && updatedUser?.email == pendingEmail) {

                                          timer.cancel();

                                          await syncEmailWithDatabase();

                                          setState(() {
                                            isVerifying = false;
                                            isEmailVerified = true;
                                            emailController.text = pendingEmail!;
                                          });

                                          pendingEmail = null;

                                          Get.snackbar(
                                            AppStrings.success,
                                            AppStrings.emailVerifiedSuccess,
                                            backgroundColor: Colors.green.shade100,
                                          );
                                        }
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == "requires-recent-login") {
                                        final password =
                                            await _showPasswordDialog();

                                        if (password == null ||
                                            password.isEmpty)
                                          return;

                                        try {
                                          await reAuthenticateUser(password);

                                          /// RETRY AFTER RE-AUTH
                                          await user.verifyBeforeUpdateEmail(
                                            newEmail,
                                          );

                                          await db.child(user.uid).update({
                                            "emailVerified": false,
                                          });

                                          setState(() {
                                            isEmailVerified = false;
                                            isVerifying = true;
                                          });

                                          Get.snackbar(
                                            AppStrings.emailSent,
                                            "${AppStrings.verificationSendTo} $newEmail",
                                            backgroundColor:
                                                Colors.green.shade100,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            AppStrings.error,
                                            AppStrings.reAuthFailed,
                                            backgroundColor:
                                                Colors.red.shade100,
                                          );
                                        }

                                        return;
                                      }

                                      Get.snackbar(
                                        AppStrings.error,
                                        AppStrings.failedToSendEmail,
                                        backgroundColor: Colors.red.shade100,
                                      );
                                    }
                                  },

                                  child: isVerifying
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isEmailVerified
                                              ? AppStrings.verified
                                              : AppStrings.verify,
                                          style: TextStyle(
                                            color: isEmailVerified
                                                ? Colors.green
                                                : AppColors.themeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            buildField(
                              AppStrings.firstName,
                              Icons.person_outline,
                              firstNameController,
                            ),

                            const SizedBox(height: 15),

                            buildField(
                              AppStrings.lastName,
                              Icons.person,
                              lastNameController,
                            ),

                            const SizedBox(height: 15),

                            TextField(
                              controller: authController.dobController,
                              readOnly: true,
                              onTap: () => authController.pickDOB(context),
                              decoration: InputDecoration(
                                labelText: AppStrings.dateOfBirth,
                                prefixIcon: const Icon(Icons.cake),
                                suffixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            buildField(
                              AppStrings.gender,
                              Icons.people,
                              genderController,
                            ),

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
                                onPressed: isUpdating ? null : updateProfile,
                                child: const Text(
                                  AppStrings.updateProfile,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

/// LOGOUT FUNCTION
Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
  Get.offAllNamed(AppRoutes.signin);
}

/// show dialog box for logout confirmation
void showLogoutDialog() {
  Get.dialog(
    Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),

            const SizedBox(height: 15),

            /// TITLE
            const Text(
              AppStrings.logoutQ,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// MESSAGE
            const Text(
              AppStrings.logoutConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                /// CANCEL
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(AppStrings.cancel),
                  ),
                ),

                const SizedBox(width: 10),

                /// LOGOUT
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back(); // close dialog
                      await logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      AppStrings.logout,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

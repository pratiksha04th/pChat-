import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Profile/view/profile_edit_screen.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../Core/Widgets/bottom_nav_bar.dart';
import '../../ShowFriends/controller/friend_request_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final DatabaseReference db = FirebaseDatabase.instance.ref("users");
  final friendsController = Get.find<FriendRequestController>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();

  bool isLoading = true;

  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await db.child(user.uid).get();

    if (snapshot.exists) {

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        username = data["username"] ?? "";
        email = data["email"] ?? "";

        firstNameController.text = data["firstName"] ?? "";
        lastNameController.text = data["lastName"] ?? "";
        dobController.text = data["dob"] ?? "";
        genderController.text = data["gender"] ?? "";

        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await db.child(user.uid).update({
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "dob": dobController.text.trim(),
      "gender": genderController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated Successfully"),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              AppImages.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 20),

                /// AVATAR
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.themeColor,
                  child: Text(
                    username.isNotEmpty
                        ? username[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),

                /// EDIT PROFILE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: AppColors.themeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        /// navigate to edit screen
                        Get.to(() => ProfileEditScreen());
                      },
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// FRIENDS SECTION TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Text(
                        "Friends",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// FRIENDS LIST (like posts section)
                Obx(() {

                  final friends = friendsController.friends;

                  if (friends.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No friends yet"),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {

                      final user = friends[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Row(
                          children: [

                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              AppColors.themeColor.withOpacity(.2),
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.themeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}
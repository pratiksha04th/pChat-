import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Profile/view/profile_edit_screen.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../Core/routes/app_routes.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../../Home/widget/post_card_ui.dart';
import '../../PostScreen/controller/post_controller.dart';
import '../../ShowFriends/controller/friend_request_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final DatabaseReference db = FirebaseDatabase.instance.ref("users");
  final postController = Get.find<PostController>();
  final FriendRequestController friendsController = Get.find();

  final uid = FirebaseAuth.instance.currentUser!.uid;

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

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                        : AppStrings.defaultAvatar,
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

                /// EDIT PROFILE & FRIENDS BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [

                      /// EDIT PROFILE
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.themeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Get.to(() => ProfileEditScreen());

                            await loadUserData();
                          },
                          child: const Text(
                            AppStrings.editProfile,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// FRIENDS BUTTON
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.themeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Get.toNamed(AppRoutes.allFriends);
                          },
                          child: const Text(
                            AppStrings.friends,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// POSTS/ RESHARE POST SECTION TITLE
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [

                        /// TAB BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.6),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: AppColors.themeColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicatorAnimation: TabIndicatorAnimation.elastic,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black54,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                              tabs: const [
                                Tab(text: AppStrings.posts),
                                Tab(text: AppStrings.reshares),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// TAB VIEW
                        Expanded(
                          child: TabBarView(
                            children: [

                              /// POSTS
                              _buildMyPosts(),

                              /// RESHARES
                              _buildMyReshares(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildMyPosts() {
    return Obx(() {
      final posts = postController.myFeed
          .where((e) => e['originalPostId'] == null)
          .toList();

      if (posts.isEmpty) {
        return const Center(child: Text(AppStrings.noPosts));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            key: ValueKey(posts[index]['postId']),
            postData: Map<String, dynamic>.from(posts[index]),
          );
        },
      );
    });
  }

  Widget _buildMyReshares() {
    return Obx(() {
      final reshares = postController.myFeed
          .where((e) => e['originalPostId'] != null)
          .toList();

      if (reshares.isEmpty) {
        return const Center(child: Text(AppStrings.noReshares));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: reshares.length,
        itemBuilder: (context, index) {
          return PostCard(
            key: ValueKey(reshares[index]['postId']),
            postData: Map<String, dynamic>.from(reshares[index]),
          );
        },
      );
    });
  }
}
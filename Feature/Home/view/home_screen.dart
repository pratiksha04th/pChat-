import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Core/routes/app_routes.dart';
import 'package:pchat/Feature/Animation/postAnimation/animated_post.dart';
import 'package:pchat/Feature/Home/widget/post_card_ui.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../Core/services/connectivity_service.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../../PostScreen/controller/post_controller.dart';
import '../../PostScreen/view/create_post_screen.dart';
import '../controller/userController/all_users_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// TOP BAR
                _topBar(),

                const SizedBox(height:10),
                /// QUICK POST
                _quickPost(),

                const SizedBox(height: 10),

                /// POSTS LIST
                Expanded(
                  child: Obx(() {
                    final postController = Get.find<PostController>();

                    return Stack(
                      children: [

                        /// POSTS STREAM
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: postController.getFriendsPosts(),
                          builder: (context, snapshot) {

                            /// INITIAL LOADING
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final posts = snapshot.data ?? [];

                            /// EMPTY STATE
                            if (posts.isEmpty) {
                              return const Center(
                                child: Text(
                                  AppStrings.noPosts,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                final connectivity = Get.find<ConnectivityService>();

                                if (!connectivity.isOnline.value) {
                                  Get.snackbar(AppStrings.noInternet,
                                      AppStrings.checkInternet);
                                  return;
                                }

                                await postController.refreshPosts();
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {

                                  final postData = Map<String, dynamic>.from(posts[index]);

                                  return AnimatedPostWrapper(
                                    child: PostCard(
                                      key: ValueKey(postData['postId']),
                                      postData: postData,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        /// TOP LOADER (WHEN REFRESHING)
                        if (postController.isRefreshing.value)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// TOP BAR
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18 ),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [

            /// CENTER LOGO + TEXT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                    scale: 1.5,
                    child: Image.asset(AppImages.logo),
                  ),
                ),

                const SizedBox(width: 8),

                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            /// NOTIFICATION ICON
            Positioned(
              right: 0,
              top: 13,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.friendRequest);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: AppColors.themeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// QUICK POST CARD
  Widget _quickPost() {

    final userController = Get.find<AllUsersController>();

    return Obx(() {

      final username = userController.currentUserUsername.value;

      final firstLetter =
      username.isNotEmpty ? username[0].toUpperCase() : AppStrings.defaultAvatar;

      return GestureDetector(
        onTap: () {
          Get.to(() => const CreatePostScreen());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),
          child: Row(
            children: [

              /// AVATAR
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.lightAvatarGradient,
                  border: Border.all(
                    color: AppColors.themeColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.themeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  AppStrings.whatsOnMind,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.themeColor),
                ),
                child: const Text(AppStrings.create),
              ),
            ],
          ),
        ),
      );
    });
  }
}

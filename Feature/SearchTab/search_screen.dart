import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Core/services/connectivity_service.dart';
import '../Chat_Screen/controller/chat_controller.dart';
import '../Chat_Screen/view/chat_screen.dart';
import '../ShowFriends/controller/friend_request_controller.dart';
import '../Home/controller/userController/all_users_controller.dart';
import '../../utilities/App_Colors/App_Colors.dart';
import '../../utilities/App_Images/App_Images.dart';
import '../../utilities/App_Strings/app_strings.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find();
  final FriendRequestController requestController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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

                /// LOGO + TITLE
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

                const SizedBox(height: 20),

                /// SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: usersController.onSearchChanged,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: AppStrings.searchUsers,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// USERS LIST
                Expanded(
                  child: Obx(() {
                    if (usersController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (usersController.filteredUsers.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(AppStrings.noUser),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final connectivity = Get.find<ConnectivityService>();

                        if (!connectivity.isOnline.value) {
                          Get.snackbar(
                            AppStrings.noInternet,
                            AppStrings.checkInternet,
                          );
                          return;
                        }
                        await usersController.refreshUsers();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: usersController.filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = usersController.filteredUsers[index];

                          return _contactTile(
                            uid: user.uid,
                            username: user.username,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            gender: user.gender,
                            dob: user.dob,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CONTACT TILE
  Widget _contactTile({
    required String uid,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
  }) {
    int age = 0;

    if (dob.isNotEmpty) {
      final parts = dob.split("-");
      if (parts.length == 3) {
        final birthYear = int.tryParse(parts[2]) ?? 0;
        age = DateTime.now().year - birthYear;
      }
    }

    final fullName = "$firstName $lastName".trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          /// AVATAR
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.lightAvatarGradient,
              border: Border.all(color: AppColors.themeColor, width: 1),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.transparent,
              child: Text(
                username.isNotEmpty
                    ? username[0].toUpperCase()
                    : AppStrings.defaultAvatar,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// USER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FULL NAME
                Text(
                  "$username",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                /// USERNAME
                Text(
                  fullName.isEmpty ? username : fullName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                /// AGE + GENDER
                Row(
                  children: [
                    if (age > 0)
                      Text(
                        "$age ${AppStrings.yearsShort}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                    if (age > 0 && gender.isNotEmpty) const SizedBox(width: 8),

                    if (gender.isNotEmpty)
                      Text(
                        gender,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          /// ADD FRIEND BUTTON
          Flexible(
            child: Obx(() {
              final req = requestController.requests[uid];
              final currentUid = requestController.currentUser?.uid;

              if (uid == currentUid) return const SizedBox();

              /// NO REQUEST -> ADD FRIEND
              if (req == null) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    requestController.sendRequest(uid);
                  },
                  child: FittedBox(child: const Text(AppStrings.addFriend)),
                );
              }

              /// PENDING
              if (req.status == "pending") {
                /// RECEIVED REQUEST
                if (req.toUid == currentUid) {
                  return FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            requestController.acceptRequest(req.requestId);
                          },
                          child: const Text(AppStrings.accept),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            requestController.rejectRequest(req.requestId);
                          },
                          child: const Text(AppStrings.reject),
                        ),
                      ],
                    ),
                  );
                }

                /// SENT REQUEST
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: null,
                  child: const Text(AppStrings.pending),
                );
              }

              /// ACCEPTED
              if (req.status == "accepted") {
                return TextButton(
                  onPressed: () {
                    _openChat(uid, username);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: Colors.green),
                      const SizedBox(width: 10),
                      const Text(
                        AppStrings.friends,
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            }),
          ),
        ],
      ),
    );
  }

  void _openChat(String uid, String username) async {
    final chatId = await chatController.openChat(
      otherUid: uid,
      otherName: username,
    );

    Get.to(
      () => ChatScreen(chatId: chatId, username: username, otherUserId: uid),
    );
  }
}

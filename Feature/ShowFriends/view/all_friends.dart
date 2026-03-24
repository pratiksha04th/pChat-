import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/routes/app_routes.dart';
import '../../../Core/services/connectivity_service.dart';
import '../../Chat_Screen/controller/chat_controller.dart';
import '../../Chat_Screen/view/chat_screen.dart';

import '../../../utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Images/App_Images.dart';

import '../../Home/controller/userController/all_users_controller.dart';
import '../controller/friend_request_controller.dart';

class AllFriends extends StatelessWidget {
  AllFriends({super.key});

  final RxInt selectedTab = 0.obs;
  final RxBool isRefreshing = false.obs;

  final FriendRequestController requestController = Get.find();
  final ChatController chatController = Get.find();
  final AllUsersController usersController = Get.find();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,

        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            Get.back();
                          },
                        ),

                      const SizedBox(width: 65),

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
                        "pChat",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        onChanged: requestController.onSearchChanged,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Search friends",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// LIST VIEW
                  Expanded(
                    child: Obx(() {
                      final friends = requestController.filteredFriends;

                      final isLoading = requestController.isRefreshing.value;

                      if (isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (friends.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text("No friends yet"),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefreshFriends,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final user = friends[index];

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
      floatingActionButton: Obx(() {
        final count = usersController.selectedGroupUsers.length;

        return FloatingActionButton.extended(
          backgroundColor: AppColors.themeColor,
          foregroundColor: Colors.white,
          icon: Icon(count > 0 ? Icons.check : Icons.group_add),
          label: Text(count > 0 ? "Create ($count)" : "Create Group"),
          onPressed: () {
            if (count > 0) {
              final selectedUids = usersController.selectedGroupUsers.toList();

              Get.toNamed(
                AppRoutes.createGroup,
                arguments: selectedUids,
              );
            } else {
              usersController.startGroupSelection();
            }
          },
        );
      }),
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

    return Obx(() {
      final isSelecting =
          usersController.selectedGroupUsers.isNotEmpty;
      final isSelected =
      usersController.selectedGroupUsers.contains(uid);

      return GestureDetector(
        onTap: () {
          if (isSelecting) {
            usersController.toggleGroupUser(uid);
          } else {
            _openChat(uid, username);
          }
        },

        onLongPress: () {
          usersController.startGroupSelection();
          usersController.toggleGroupUser(uid);
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.themeColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                AppColors.themeColor.withOpacity(.15),
                child: Text(
                  username.isNotEmpty
                      ? username[0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.themeColor,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty
                          ? username
                          : fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "@$username",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        if (age > 0)
                          Text("$age yrs",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.grey.shade600)),

                        if (age > 0 &&
                            gender.isNotEmpty)
                          const SizedBox(width: 8),

                        if (gender.isNotEmpty)
                          Text(gender,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),

              /// RIGHT SIDE BUTTON / CHECKBOX
              Obx(() {
                if (isSelecting) {
                  return Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      usersController
                          .toggleGroupUser(uid);
                    },
                  );
                }

                final req =
                requestController.requests[uid];
                final currentUid =
                    requestController.currentUser?.uid;

                if (req != null &&
                    req.fromUid == currentUid &&
                    req.status == "pending") {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey),
                    onPressed: null,
                    child: const Text("Pending"),
                  );
                }

                if (req != null &&
                    req.toUid == currentUid &&
                    req.status == "pending") {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () {
                      requestController
                          .acceptRequest(req.requestId);
                    },
                    child: const Text("Accept"),
                  );
                }

                if (req != null &&
                    req.status == "accepted") {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.themeColor,
                        foregroundColor: Colors.white),
                    onPressed: () =>
                        _openChat(uid, username),
                    child: const Text("Start Chat"),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.themeColor),
                  onPressed: () =>
                      requestController.sendRequest(uid),
                  child: const Text("Add Friend"),
                );
              }),
            ],
          ),
        ),
      );
    });
  }


  void _openChat(String uid, String name) async {
    final chatId =
    await chatController.openChat(otherUid: uid, otherName: name);

    Get.to(() => ChatScreen(chatId: chatId, username: name, otherUserId: uid));
  }

  Future<void> _onRefreshFriends() async {
    final connectivity = Get.find<ConnectivityService>();

    if (!connectivity.isOnline.value) {
      Get.snackbar(
        "No Internet",
        "Check your connection",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await requestController.refreshFriends();
    } catch (e) {
      Get.snackbar("Error", "Failed to refresh");
    }
  }
}
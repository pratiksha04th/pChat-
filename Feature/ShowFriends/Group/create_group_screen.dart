import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utilities/App_Images/App_Images.dart';
import '../../Chat_Screen/controller/chat_controller.dart';
import '../../Chat_Screen/model/chat_room.dart';
import '../../Chat_Screen/view/chat_screen.dart';
import '../../Home/controller/userController/all_users_controller.dart';
import '../../../utilities/App_Colors/App_Colors.dart';

class CreateGroupScreen extends StatelessWidget {
  final List<String> selectedUserIds;
  CreateGroupScreen({super.key, required this.selectedUserIds});

  final TextEditingController nameController = TextEditingController();
  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedUsers = usersController.users
          .where((u) => usersController.selectedGroupUsers.contains(u.uid))
          .toList();

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

            /// CONTENT
            SafeArea(
              child: Column(
                children: [
                  /// APP BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Get.back(),
                        ),

                        const Spacer(),

                        const Text(
                          "New Group",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),


                  /// MAIN CARD CONTAINER
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          /// GROUP NAME FIELD
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.group,
                                      color: AppColors.themeColor),
                                  hintText: "Enter group name",
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// MEMBERS HEADER
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Row(
                              children: [
                                Text(
                                  "Members (${selectedUsers.length})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    usersController.groupSelectionMode.value = true;
                                    Get.back();
                                  },
                                  child: Text(
                                    "Add Members",
                                    style: TextStyle(
                                      color: AppColors.themeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// MEMBERS LIST
                          Expanded(
                            child: ListView.builder(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: selectedUsers.length,
                              itemBuilder: (context, index) {
                                final user = selectedUsers[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                        AppColors.themeColor.withOpacity(.15),
                                        child: Text(
                                          user.username[0].toUpperCase(),
                                          style: TextStyle(
                                            color: AppColors.themeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          user.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          usersController.toggleGroupUser(user.uid);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          /// CREATE BUTTON
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.themeColor,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  final groupName =
                                  nameController.text.trim();

                                  if (groupName.isEmpty) {
                                    Get.snackbar(
                                        "Error", "Please enter a group name");
                                    return;
                                  }

                                  if (selectedUsers.isEmpty) {
                                    Get.snackbar("Error",
                                        "Select at least one member");
                                    return;
                                  }

                                  final members =
                                  selectedUsers.map((user) {
                                    return ChatParticipant(
                                      id: user.uid,
                                      name: user.username,
                                    );
                                  }).toList();

                                  final groupId =
                                  await chatController.createGroup(
                                    groupName: groupName,
                                    members: members,
                                  );

                                  usersController.clearGroupSelection();

                                  Get.off(() => ChatScreen(
                                    chatId: groupId,
                                    username: groupName,
                                    otherUserId: "",
                                  ));
                                },
                                child: const Text(
                                  "Create Group",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
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
          ],
        ),
      );
    });
  }
}

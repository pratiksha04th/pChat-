import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Home/view/home_screen.dart';

import '../Chat_Screen/controller/chat_controller.dart';
import '../Chat_Screen/model/chat_room.dart';
import '../Home/controller/userController/all_users_controller.dart';
import '../../utilities/App_Colors/App_Colors.dart';

class CreateGroupScreen extends StatelessWidget {
  CreateGroupScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    final selectedIds = usersController.selectedGroupUsers;

    final selectedUsers = usersController.users
        .where((u) => selectedIds.contains(u.uid))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: const Text("Create Group", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Group Name Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter group name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Members Title
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Members",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: (){ Get.back();}, child: Text("Edit", style: TextStyle(color: AppColors.themeColor, fontWeight: FontWeight.bold)))
                  )
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Members List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = selectedUsers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : "U",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Create Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
              final groupName = nameController.text.trim();

              if (groupName.isEmpty) {
              Get.snackbar("Error", "Please enter a group name");
              return;
              }

              if (selectedUsers.isEmpty) {
              Get.snackbar("Error", "Select at least one member");
              return;
              }

              final members = selectedUsers.map((user) {
                return ChatParticipant(
                  id: user.uid,
                  name: user.username,
                );
              }).toList();

              await chatController.createGroup(
                groupName: groupName,
                members: members,
              );

              usersController.clearGroupSelection();

              Get.offAll(() => HomeScreen());
              },
                  child: const Text(
                    "Create Group",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

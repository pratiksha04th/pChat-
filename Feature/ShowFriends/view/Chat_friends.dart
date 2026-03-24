import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/ShowFriends/view/all_friends.dart';

import '../../../Core/Widgets/bottom_nav_bar.dart';
import '../../../Core/services/connectivity_service.dart';
import '../../../utilities/App_Colors/App_Colors.dart';
import '../../Chat_Screen/controller/chat_controller.dart';
import '../../Chat_Screen/view/chat_screen.dart';
import '../../Chat_Screen/model/chat_room.dart';

import '../../AiAssistant/Features/CallScreen/view/call_screen.dart';
import '../../AiAssistant/Features/PermissionScreen/view/permission_view.dart';


import '../../../utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Images/App_Images.dart';

import '../../../Core/SharedPreferences/session_manager.dart';
import '../../Home/controller/userController/all_users_controller.dart';
import '../controller/friend_request_controller.dart';

class ChatFriends extends StatelessWidget {
  ChatFriends({super.key});

  final FriendRequestController requestController = Get.find();
  final ChatController chatController = Get.find();
  final AllUsersController usersController = Get.find();


  // format time
  String formatDateTime(int timestamp) {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? "PM" : "AM";

    final isToday =
        now.year == time.year &&
            now.month == time.month &&
            now.day == time.day;

    final isYesterday =
        now.subtract(const Duration(days: 1)).year == time.year &&
            now.subtract(const Duration(days: 1)).month == time.month &&
            now.subtract(const Duration(days: 1)).day == time.day;

    if (isToday) {
      return "$hour:$minute $amPm";
    } else if (isYesterday) {
      return "Yesterday, $hour:$minute $amPm";
    } else {
      return "${time.day}/${time.month}/${time.year}, $hour:$minute $amPm";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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

                  /// LOGO
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
                        "pChat",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                        onChanged: chatController.onSearchChanged,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Search friends",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// TAB SWITCH
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
                          Tab(text: "Chats"),
                          Tab(text: "Groups"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LIST VIEW
                  Expanded(
                    child: TabBarView(
                      children: [

                        /// FRIENDS
                        Obx(() {

                          final rooms = chatController.filterChats;

                          if (rooms.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 50, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text("No chats yet"),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh:() async {
                              final conncetivity = Get.find<ConnectivityService>();

                              if (!conncetivity.isOnline.value) {
                                Get.snackbar("No Internet",
                                    "Please check your internet connection");
                                return;
                              }
                              await chatController.refreshChats();
                            } ,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: rooms.length,
                              itemBuilder: (context, index) {

                                final room = rooms[index];

                                final participants = room.participants;

                                final otherUser = participants.firstWhere(
                                      (p) => p.id != requestController.currentUser?.uid,
                                );
                                if (otherUser == null) return const SizedBox();


                                final user = usersController.users
                                    .firstWhereOrNull((u) => u.uid == otherUser.id);

                                if (user == null) return const SizedBox();

                                return _chatTile(room, user);
                              },
                            ),
                          );
                        }),

                        /// GROUPS
                        Obx(() {
                          final groups = chatController.filterGroups;

                          if (groups.isEmpty) {
                            return const Center(child: Text("No Groups Found"));
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              final group = groups[index];
                              return _groupTile(group);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// FLOATING BUTTONS
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "ai",
                backgroundColor: AppColors.themeColor,
                child: Image.asset(AppImages.Ailogo, height: 30),
                onPressed: () async {
                  final permission = await SessionManager.isPermissionGiven();

                  if (!permission) {
                    Get.to(() => PermissionView(onAllow: () {}));
                  } else {
                    Get.to(() => CallScreen(onEndCall: () => Get.back()));
                  }
                },
              ),

              const SizedBox(height: 12),

              FloatingActionButton(
                heroTag: "add",
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
                onPressed: () {
                  Get.to(() => AllFriends());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CHAT TILE
  Widget _chatTile(ChatRoom room, user) {

    final fullName = "${user.firstName} ${user.lastName}".trim();
    final lastMsg = room.lastMsg.text;

    return GestureDetector(
      onTap: () {
        _openChat(user.uid, user.username, );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.themeColor.withOpacity(.15),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    fullName.isEmpty ? user.username : fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    lastMsg.isEmpty ? "Say hello 👋" : lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              formatDateTime(room.lastMsg.time ),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _groupTile(ChatRoom group) {
    final lastMsg = group.lastMsg.text;

    return GestureDetector(
      onTap: () {
        Get.to(() => ChatScreen(
          chatId: group.chatRoomId,
          username: group.groupName,
          otherUserId: "",
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            /// GROUP AVATAR
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.themeColor.withOpacity(.15),
              child: Text(
                group.groupName.isNotEmpty
                    ? group.groupName[0].toUpperCase()
                    : "G",
                style: TextStyle(
                  color: AppColors.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// NAME + LAST MESSAGE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.groupName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    lastMsg.isEmpty ? "Start Chat" : lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// TIME
            Text(
              formatDateTime(group.lastMsg.time),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _openChat(String uid, String name) async {
    final chatId =
    await chatController.openChat(otherUid: uid, otherName: name, );

    Get.to(() => ChatScreen(chatId: chatId, username: name, otherUserId: uid));
  }
}
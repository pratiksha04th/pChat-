import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Auth/view/SignIn/SignIn.dart';
import '../../../Core/SharedPreferences/session_manager.dart';
import '../../Chat_Screen/controller/chat_controller.dart';
import '../controller/userController/all_users_controller.dart';
import '../../../Core/Widgets/home_app_bar.dart';
import '../../AiAssistant/Features/CallScreen/view/call_screen.dart';
import '../../AiAssistant/Features/PermissionScreen/view/permission_view.dart';
import '../../Chat_Screen/model/chat_room.dart';
import '../../../utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Images/App_Images.dart';
import '../../Chat_Screen/view/chat_screen.dart';
import '../../Group/create_group_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  DateTime? _lastBackPressed;
  final RxInt selectedTab = 0.obs; // 0 for chats and 1 for group
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

         Fluttertoast.showToast(
           msg: "Press again to exit",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.BOTTOM,

         );
          return false;
        }
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(),
          backgroundColor: AppColors.splashBgColor,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          //-------------------- APP BAR ------------------------
          appBar:HomeAppBar(scaffoldKey: _scaffoldKey,
              selectedTabIndex: selectedTab,
              onTabChanged: (index) {
            selectedTab.value = index;
            if (index == 1) {
             usersController.clearGroupSelection();
            }
              } ,
              ),

          //------------------ BODY --------------------
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              if(details.primaryVelocity != null && details.primaryVelocity! > 500){
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      // PERSONAL CHATS
                      Obx(() {
                        if (usersController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: usersController.filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = usersController.filteredUsers[index];

                            return _contactTile(
                              username: user.username.isNotEmpty
                                  ? user.username
                                  : "User",
                              email: user.email,
                              uid: user.uid,
                            );
                          },
                        );
                      }),

                      // GROUPS
                      Obx(() {
                        if (chatController.groups.isEmpty) {
                          return const Center(child: Text("No Groups Yet"));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: chatController.groups.length,
                          itemBuilder: (context, index) {
                            final group = chatController.groups[index];

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
          bottomNavigationBar: _buildSelectedMembersBottomSheet(),
          floatingActionButton: Obx(() {
            final selecting = usersController.groupSelectionMode.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // AI BUTTON
                FloatingActionButton(
                  heroTag: "ai_button",
                  backgroundColor: AppColors.themeColor,
                  child: Image.asset(
                    AppImages.Ailogo,
                    height: 35,
                  ),
                    onPressed: () async {

                      final permissionGiven =
                      await SessionManager.isPermissionGiven();

                      if (!permissionGiven) {

                        Get.to(() => PermissionView(
                          onAllow: () {},
                        ));

                      } else {

                        Get.to(() => CallScreen(
                          onEndCall: () => Get.back(),
                        ));

                      }

                    }
                ),

                const SizedBox(height: 12),

                // + BUTTON
                FloatingActionButton(
                  heroTag: "add_button",
                  backgroundColor: AppColors.themeColor,
                  child: Icon(
                    selecting ? Icons.check : Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedTab.value == 0) {
                      if (!selecting) {
                        usersController.startGroupSelection();
                      } else {
                        usersController.clearGroupSelection();
                      }
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ---------------- CONTACT TILE ----------------

  Widget _contactTile({
    required String username,
    required String email,
    required String uid,
  }) {
    return Obx(() {
      final isSelecting = usersController.groupSelectionMode.value;
      final isSelected = usersController.selectedGroupUsers.contains(uid);

      final chatId = _getPersonalChatId(uid);

      // find unread count from the chatController
      final room = chatController.groups
          .firstWhereOrNull((c) => c.chatRoomId == chatId);

      final int unreadCount = room?.unreadCount ?? 0;

      return GestureDetector(
        onTap: () {
          if (isSelecting) {
            usersController.toggleGroupUser(uid);
          } else {
            chatController.clearUnread(chatId);
            _openChat(uid, username);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // PROFILE AVATAR
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() :"U",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.themeColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // USER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // UNREAD BADGE
              if(unreadCount >0)
                Container(
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 99? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),


              if (isSelecting) ...[
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.themeColor : Colors.grey,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ---------------- GROUP TILE ----------------
  Widget _groupTile(ChatRoom group) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ChatScreen(chatId: group.chatRoomId, username: group.groupName),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Text(
                group.groupName.isNotEmpty ? group.groupName[0].toUpperCase() :"G",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Text(
                group.groupName.isNotEmpty ? group.groupName : "Unnamed Group",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------- bottomSheet while selecting the member -----------
  Widget _buildSelectedMembersBottomSheet() {
    return Obx(() {
      final selectedIds = usersController.selectedGroupUsers;

      if (!usersController.groupSelectionMode.value ||
          selectedIds.isEmpty || selectedTab.value != 0) {
        return const SizedBox();
      }

      final selectedUsers = usersController.users
          .where((u) => selectedIds.contains(u.uid))
          .toList();

      return AnimatedContainer(
        height: 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Selected Avatars
            Expanded(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user = selectedUsers[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : "U",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.themeColor,
                              ),
                            ),
                          ),

                          // Cancel button
                          Positioned(
                            right: -2,
                            top: -2,
                            child: GestureDetector(
                              onTap: () {
                                usersController.toggleGroupUser(user.uid);
                              },
                              child: Container(
                                decoration:BoxDecoration(
                                  color: AppColors.themeColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // NEXT Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal:22, vertical: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              onPressed: () {
                if(selectedUsers.isEmpty){
                  Get.snackbar("Error", "Select at least 1 member");
                  return;
                }
                Get.to(() => CreateGroupScreen());
              },
              child: const Text(
                "Next",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    });
  }


  // ----- openChat for group --------
  void _openChat(String uid, String name) async {
    final chatId = await chatController.openChat(
      otherUid: uid,
      otherName: name,
    );

    Get.to(() => ChatScreen(chatId: chatId, username: name,));
  }

  // --------drawer -----------
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // HEADER
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.themeColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),

            ),

            accountName: Text(usersController.currentUserUsername.value),

            accountEmail: Text(usersController.currentUserEmail.value),

            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                usersController.currentUserUsername.value.isNotEmpty
                    ? usersController.currentUserUsername.value[0].toUpperCase()
                    : "U",
                style: TextStyle(fontSize: 24, color: AppColors.themeColor),
              ),
            ),
          ),

          // ITEMS
          ListTile(
            minTileHeight: 30,
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Get.back();
            },
          ),
          const Divider(

          ),
          ListTile(
            minTileHeight: 30,
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Get.back();
            },
          ),
          const Divider(),
          ListTile(
            minTileHeight: 30,
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // ------Logout dialog --------
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        title: const Text("Logout"),

        content: const Text(
          "Are you sure you want to logout?",
        ),

        actions: [

          // CANCEL
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
            },
            child: const Text("Cancel"),
          ),

          // LOGOUT
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await SessionManager.clearSession();

              Get.back(); // close dialog

              // Clear all previous screens
              Get.offAll(() => const SignInScreen());
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  // for personal chat
  String _getPersonalChatId(String otherUid) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return myUid.compareTo(otherUid) < 0
        ? "${myUid}_$otherUid"
        : "${otherUid}_$myUid";
  }

}

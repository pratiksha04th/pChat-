import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// FEATURES
import '../../Feature/Home/controller/userController/all_users_controller.dart';
import '../../Feature/Chat_Screen/controller/chat_controller.dart';

///UTILITIES
import '../../utilities/App_Colors/App_Colors.dart';
import '../../utilities/App_Images/App_Images.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeAppBar({
    super.key,
    required this.scaffoldKey,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final RxInt selectedTabIndex;
  final Function(int) onTabChanged;

  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find();

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.splashBgColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,

      // -------- TITLE ----------
      title: Obx(() {
        final selecting = usersController.groupSelectionMode.value;
        final count = usersController.selectedGroupUsers.length;

        if (selecting) {
          return Text(
            "$count selected",
            style: const TextStyle(color: Colors.black),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.logo, height: 40),
            const SizedBox(width: 6),
            const Text(
              "pChat",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        );
      }),

      // -------- BOTTOM ----------
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(110),

        child: Column(
          children: [

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [

                  // MENU
                  IconButton(
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                  const SizedBox(width: 5),
                  // SEARCH
                  Expanded(
                    child: TextField(
                      onChanged: (value){
                        if (selectedTabIndex == 0) {
                          usersController.onSearchChanged(value);
                        } else {
                          chatController.onGroupSearchChanged(value);
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor:
                        AppColors.themeColor.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TABS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.splashBgColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),

              child: TabBar(
                onTap: onTabChanged,

                indicator: BoxDecoration(
                  color: AppColors.themeColor,
                  borderRadius: BorderRadius.circular(12),
                ),

                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,

                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle:
                const TextStyle(fontWeight: FontWeight.w600),

                tabs: const [
                  Tab(text: "Chats"),
                  Tab(text: "Groups"),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

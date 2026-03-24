import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/Core/services/connectivity_service.dart';

import '../../Feature/Home/view/home_screen.dart';
import '../../Feature/Profile/view/profile_screen.dart';
import '../../Feature/ShowFriends/view/Chat_friends.dart';
import '../../Feature/ShowFriends/view/friend_request.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../controller/pchat_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PChatController controller = Get.find();
  final connectivity = Get.find<ConnectivityService>();

  bool _wasOffline = false;
  final RxBool showOnlineBanner = false.obs;
  late Worker _worker;

  final List<Widget> pages = [
    HomeScreen(),
    ChatFriends(),
    FriendRequest(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _worker = ever(connectivity.isOnline, (bool online) async {

      /// offline
      if (!online) {
        _wasOffline = true;
        return;
      }

      /// online
      if (online && _wasOffline) {
        showOnlineBanner.value = true;

        await Future.delayed(const Duration(seconds: 2));

        showOnlineBanner.value = false;
        _wasOffline = false;
      }
    });
  }
  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print("Main screen open");
    return Stack(
      children: [

        /// MAIN UI
        Scaffold(
          extendBody: true,
          body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          )),
          bottomNavigationBar: PChatBottomNav(),
        ),

        /// INTERNET CONNECTIVITY STATUS
        Obx(() {
          if (!connectivity.isOnline.value) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _offline(),
            );
          }

          if (showOnlineBanner.value) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _online(),
            );
          }

          return const SizedBox();
        }),
      ],
    );
  }

  Widget _offline() {
    return Container(
      height: 40,
      color: Colors.red,
      alignment: Alignment.center,
      child: const Text(
        "No Internet Connection",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _online() {
    return Container(
      height: 40,
      color: Colors.green,
      alignment: Alignment.center,
      child: const Text(
        "Back Online",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

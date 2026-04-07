import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Images/App_Images.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../controller/friend_request_controller.dart';

class FriendRequest extends StatelessWidget {
  FriendRequest({super.key});

  final FriendRequestController controller = Get.find();
  final RxInt selectedTab = 0.obs;

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

                  /// LOGO + TITLE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.themeColor,
                          ),
                        ),
                        const SizedBox(width: 15),

                        /// LOGO
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
                          AppStrings.friendRequests,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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

                        /// smooth animation
                        indicatorAnimation: TabIndicatorAnimation.elastic,

                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black54,

                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),

                        tabs: const [
                          Tab(text: AppStrings.received),
                          Tab(text: AppStrings.sent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// LIST VIEW
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        /// RECEIVED
                        Obx(() {
                          final currentUid = controller.currentUser?.uid;

                          final received = controller.requests.values
                              .where(
                                (r) =>
                                    r.toUid == currentUid &&
                                    r.status == "pending",
                              )
                              .toList();

                          if (received.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// GRADIENT ICON
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          AppColors.themeColor,
                                          AppColors.themeColor.withOpacity(0.4),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn,
                                    child: const Icon(
                                      Icons.person_add_alt_1_outlined,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    "No friend requests yet",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: received.length,
                            itemBuilder: (context, index) {
                              final req = received[index];

                              return _requestTile(
                                uid: req.fromUid,
                                isReceived: true,
                                requestId: req.requestId,
                              );
                            },
                          );
                        }),

                        /// SENT
                        Obx(() {
                          final currentUid = controller.currentUser?.uid;

                          final sent = controller.requests.values
                              .where(
                                (r) =>
                                    r.fromUid == currentUid &&
                                    r.status == "pending",
                              )
                              .toList();

                          if (sent.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// GRADIENT ICON
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          AppColors.themeColor,
                                          AppColors.themeColor.withOpacity(0.4),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn,
                                    child: const Icon(
                                      Icons.outgoing_mail,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    "No Requests sent",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.themeColor,
                                    ),

                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: sent.length,
                            itemBuilder: (context, index) {
                              final req = sent[index];

                              return _requestTile(
                                uid: req.toUid,
                                isReceived: false,
                                requestId: req.requestId,
                              );
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
      ),
    );
  }

  /// REQUEST TILE
  Widget _requestTile({
    required String uid,
    required bool isReceived,
    required String requestId,
  }) {
    final user = controller.usersController.users.firstWhereOrNull(
      (u) => u.uid == uid,
    );

    final username = user?.username ?? "User";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          /// AVATAR (first letter of username)
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.themeColor.withOpacity(.15),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : "U",
              style: TextStyle(
                color: AppColors.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// NAME + SUBTEXT
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
                  isReceived
                      ? AppStrings.requestReceived
                      : AppStrings.requestPending,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          /// ACTIONS
          isReceived
              ? Row(
                  children: [
                    /// ACCEPT
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        controller.acceptRequest(requestId);
                      },
                      child: const Text(AppStrings.accept),
                    ),

                    const SizedBox(width: 6),

                    /// REJECT (NEW BUTTON)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        controller.rejectRequest(requestId);
                      },
                      child: const Text(AppStrings.reject),
                    ),
                  ],
                )
              /// SENT
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(AppStrings.pending, style: TextStyle(fontSize: 12)),
                ),
        ],
      ),
    );
  }
}

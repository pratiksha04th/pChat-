import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Widgets/bubble_style.dart';
import '../../../Core/services/connectivity_service.dart';
import '../../../utilities/App_Images/App_Images.dart';
import '../../Home/controller/userController/all_users_controller.dart';
import '../controller/chat_controller.dart';
import '../../../utilities/App_Colors/App_Colors.dart';
import '../model/message.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String chatId;
  final String otherUserId;


  const ChatScreen({super.key, required this.username, required this.chatId, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AllUsersController usersController = Get.find();
  final ChatController chatController = Get.find();
  final TextEditingController messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final connectivity = Get.find<ConnectivityService>();

  @override
  void initState() {
    super.initState();

    FirebaseCrashlytics.instance.log("ChatScreen opened: ${widget.chatId}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        chatController.initChat(widget.chatId);
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: "initChat failed",
        );
      }
    });
  }

  @override
  void dispose() {
    chatController.isChatOpen = false;
    messageController.dispose();
    super.dispose();
  }
/// FORMAT DATE AND TIME
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

  /// FORMAT LAST SEEN
  String _formatLastSeen(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";

    return "${time.day}/${time.month}/${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      /// APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),

            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),

            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.5),

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.themeColor),
              onPressed: () => Get.back(),
            ),

            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.themeColor.withOpacity(0.15),
                  child: Text(
                    widget.username[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Obx(() {
                      final user = usersController.users.firstWhereOrNull(
                            (u) => u.uid == widget.otherUserId,
                      );

                      if (user == null) return SizedBox();

                      if (user.isOnline) {
                        return const Text(
                          "Online",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        );
                      }

                      return Text(
                        "Last seen ${_formatLastSeen(user.lastSeen)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    })
                  ],
                ),
              ],
            ),

            actions: [
              Icon(Icons.more_vert, color: AppColors.themeColor),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),

      /// BODY
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(AppImages.backgroundImage, fit: BoxFit.cover),
          ),

          /// CONTENT
          SafeArea(
            child: Column(
              children: [
                Expanded(child: _messagesList()),
                _chatInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// RECEIVER MESSAGE
  Widget _receiverBubble(String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            child:Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1.2, color:Colors.white),
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.themeColor,
                    AppColors.themeColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            ),
            child: Center(
              child: Text(
                widget.username[0].toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          ),

          const SizedBox(width: 4),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipPath(
                  clipper: ChatBubbleClipper(isMe: false),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.blue.shade50.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text, softWrap: true),

                        const SizedBox(height: 4),

                        /// TIME
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                    SizedBox(width: 2),
                    Icon(
                      Icons.thumb_up_alt_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// SENDER MESSAGE
  Widget _senderBubble(String text, String time, MessageStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ClipPath(
              clipper: ChatBubbleClipper(isMe: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.themeColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// MESSAGE TEXT
                    Text(text, style: const TextStyle(color: Colors.white)),

                    const SizedBox(height: 4),

                    /// TIME + STATUS
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(width: 6),

                        /// STATUS ICON
                        Icon(
                          status == MessageStatus.sending
                              ? Icons.access_time_rounded
                              : Icons.check_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          /// AVATAR
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color:AppColors.themeColor),
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.blue.shade50.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  usersController.currentUserUsername.value.isNotEmpty
                      ? usersController.currentUserUsername.value[0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    color: AppColors.themeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT BAR
  Widget _chatInput() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.grey),

          const SizedBox(width: 6),

          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: InputBorder.none,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.themeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () async {
                final text = messageController.text.trim();
                if (text.isEmpty) return;

                messageController.clear();
                try {
                  await chatController.sendMessage(text);
                  messageController.clear();

                  FirebaseCrashlytics.instance.log("Message sent: $text");
                } catch (e, stack) {
                  FirebaseCrashlytics.instance.recordError(
                    e,
                    stack,
                    reason: "sendMessage UI failed",
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// DELETE DIALOG
  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Do you want to delete this message ?"),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),

          TextButton(
            onPressed: () async {
              await chatController.deleteSelectedMsg();
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _messagesList() {
    return Obx(() {
      try {
        final messages = chatController.uiMessages;

        if (messages.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];

            final isMe = msg.senderId == FirebaseAuth.instance.currentUser!.uid;

            final time = formatDateTime(msg.time);

            final selected = chatController.selectedMsgIds.contains(msg.msgId);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: selected
                  ? AppColors.themeColor.withOpacity(0.12)
                  : Colors.transparent,
              child: isMe
                  ? _senderBubble(msg.text, time, msg.status)
                  : _receiverBubble(msg.text, time),
            );
          },
        );
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: "Message list rendering failed",
        );

        return const Center(child: Text("Something went wrong"));
      }
    });
  }

  String getOtherUserUid() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final parts = widget.chatId.split('_');
    return parts.first == myUid ? parts.last : parts.first;
  }
}

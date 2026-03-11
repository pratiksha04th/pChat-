import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import '../../../utilities/App_Colors/App_Colors.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String chatId;

  ChatScreen({super.key,
    required this.username,
    required this.chatId
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.initChat(widget.chatId);
    });
  }
  @override
  void dispose(){
    chatController.isChatOpen = false;
    messageController.dispose();
    super.dispose();
  }

  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $amPm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      // ---------------- APP BAR ----------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(() {
          final selecting = chatController.selectionMode.value;
          final count = chatController.selectedMsgIds.length;

          return AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading:
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.themeColor),
              onPressed: () {
                if (selecting) {
                  chatController.clearSelection();
                } else {
                  Get.back();
                }
              },
            ),

            title: selecting
                ? Text(
                    "$count selected",
                    style: TextStyle(color: Colors.black),
                  )
                : Row(
              mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Text(
                          widget.username[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.themeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        children: [
                          Text(
                            widget.username,
                            style: TextStyle(          
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Online", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),

            actions: selecting
                ? [
                    IconButton(
                      icon: Icon(Icons.delete, color: AppColors.themeColor),
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                    ),
                  ]
                : [],
          );
        }),
      ),

      // ---------------- BODY ----------------
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: AppColors.splashBgColor,
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final message = chatController.uiMessages;
                if(message.isEmpty){
                  return const Center(
                    child: Text("No messages yet"),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: chatController.uiMessages.length,
                  itemBuilder: (context, index) {
                    final msg = chatController.uiMessages[index];

                    final isMe =
                        msg.senderId == FirebaseAuth.instance.currentUser!.uid;
                    final time = formatTime(msg.time);
                    return GestureDetector(
                      key: ValueKey(msg.msgId), // value key is used to identify the unique message
                      onLongPress: () {
                        chatController.startSelection(msg.msgId);
                      },
                      onTap: () {
                        if (chatController.selectionMode.value) {
                          chatController.toggleSelection(msg.msgId);
                        }
                      },
                      child: Obx(() {
                        final selected = chatController.selectedMsgIds.contains(
                          msg.msgId,
                        );
                        final bubble = isMe
                            ? _senderBubble(msg.text, time)
                            : _receiverBubble(msg.text, time);

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          color: selected
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.transparent,
                          child: bubble,
                        );
                      }),
                    );
                  },
                );
              }),
            ),

            _chatInput(),
          ],
        ),
      ),
    );
  }

  // ---------------- RECEIVER BUBBLE ----------------
  Widget _receiverBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child:Column(
        children: [
          Text(
            time,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: AppColors.themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SENDER BUBBLE ----------------
  Widget _senderBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: AppColors.themeColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- INPUT BAR ----------------
  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.blue.withOpacity(0.08),
      child: Row(
        children: [
          //--messageBox --
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.splashBgColor,
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.themeColor),
                    onPressed: () async {
                      final text = messageController.text.trim();
                      if (text.isEmpty) return;

                      EasyLoading.show();

                      try {
                        await chatController.sendMessage(text); // ONLY THIS
                        messageController.clear();
                      } catch (e) {
                        print("Send message error: $e");
                      } finally {
                        EasyLoading.dismiss();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 45,
            width: 45,
            decoration:BoxDecoration(
              color: AppColors.themeColor,
              borderRadius: BorderRadius.circular(20)
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
  //-------- DELETE MSG -----------

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Do you want to delete this message ?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          // Cancel
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel"),
          ),

          // Delete
          TextButton(
            onPressed: () async {
              await chatController.deleteSelectedMsg();
              Get.back(); // close dialog
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

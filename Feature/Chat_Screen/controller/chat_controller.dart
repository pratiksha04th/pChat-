import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pchat/Feature/Home/controller/userController/all_users_controller.dart';

import 'package:pchat/Feature/Chat_Screen/model/chat_room.dart';
import '../../../Core/Notification/model/notification_model.dart';
import '../../../Core/crashlytics/crashlytics_service.dart';
import '../model/message.dart';
import '../../../Core/Notification/services/send_notification_service.dart';

class ChatController extends GetxController {
  // ---- Firebase
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ------current chat
  String? chatId;

  //
  final RxList<Message> allMessages = <Message>[].obs;
  final RxList<Message> uiMessages = <Message>[].obs;
  final RxSet<String> selectedMsgIds = <String>{}.obs;
  final RxList<ChatRoom> groups = <ChatRoom>[].obs;
  final RxList<ChatRoom> filterGroups = <ChatRoom>[].obs;
  final RxString groupSearchQuery = ''.obs;

  //<----  SELECTION MODE ---->
  final RxBool selectionMode = false.obs;
  bool isInitialized = false;

  // fcmToken in cache
  final Map<String, String> _fcmCache = {};

  bool isChatOpen = false;

  // --------Listener
  StreamSubscription<DatabaseEvent>? _msgSub;
  StreamSubscription<DatabaseEvent>? _groupSub;

  @override
  void onInit() {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        listenGroups();

        ever(groupSearchQuery, (_) => _filterGroups());
      }
    });
  }

  //-----------------INIT CHAT-----------------
  void initChat(String id) async {
    chatId = id;
    isChatOpen = true;

    // CLEAR OLD MESSAGES
    allMessages.clear();
    uiMessages.clear();


    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    }

    // Clear unread count
    await _db.child("chatRooms/$id/unreadCount/$myUid").set(0);

    _msgSub?.cancel();

    //LOAD HISTORY FIRST
    await _loadInitialMessages();

    //THEN LISTEN FOR NEW MESSAGES
    _listenMessages();
  }

  // ---------------- LISTEN MESSAGES ----------------

  void _listenMessages() {
    _msgSub?.cancel();
    _msgSub = _db.child("messages").child(chatId!).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final msg = Message.fromMap(event.snapshot.key!, data);

      // Ignore deleted messages
      if (msg.isDeleted) return;

      // Add message
      if (allMessages.any((m) => m.msgId == msg.msgId)) return;
      allMessages.add(msg);

      // Sort once
      allMessages.sort((a, b) => b.time.compareTo(a.time));

      // Update UI list
      _filterUiMessages();
    });
  }

  // ---------------- FILTER UI ----------------

  void _filterUiMessages() {
    final filtered = allMessages
        .where((msg) => msg.isDeleted == false)
        .toList();

    uiMessages.value = filtered;
  }

  // ---------------- SEND MESSAGE ----------------

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final appCtrl = Get.find<AllUsersController>();

      if (appCtrl.currentUserId.isEmpty ||
          appCtrl.currentUserUsername.isEmpty) {
        await appCtrl.loadCurrentUser();
      }

      if (chatId == null) {
        throw Exception("chatId is null");
      }

      final senderId = appCtrl.currentUserId.value;
      final senderName = appCtrl.currentUserUsername.value;
      final time = DateTime.now().millisecondsSinceEpoch;

      // Save message
      final ref = _db.child("messages").child(chatId!).push();
      final msgId = ref.key!;

      await ref.set({
        "msgId": msgId,
        "senderId": senderId,
        "senderName": senderName,
        "text": text,
        "time": time,
        "isDeleted": false,
      });

      // Update chatRoom
      await _db.child("chatRooms/$chatId").update({
        "lastUpdated": time,
        "lastMsg": {
          "msgId": msgId,
          "msgText": text,
          "senderName": senderName,
          "timeStamp": time,
        },
      });
      //log
      CrashlyticsService.log(
        "Sending message to chatId: $chatId",
      );
      // Unread count
      final receiverUid = getReceiverUid();

      await _db
          .child("chatRooms/$chatId/unreadCount/$receiverUid")
          .runTransaction((value) {
            final current = (value as int?) ?? 0;
            return Transaction.success(current + 1);
          });

      // Send notification
      if (receiverUid != senderId) {
        final token = await getUserFcmToken(receiverUid);
        if (token != null && token.isNotEmpty) {
          await SendNotificationService.send(
            notification: PushNotificationModel(
              token: token,
              title: senderName,
              body: text,
              chatId: chatId!,
              conversationTitle: senderName,
              sender: senderName,
              message: text,
            ),
          );
        }
      }
    } catch (e, stack) {
      CrashlyticsService.setKey("chatId", chatId?? "unknown");
      CrashlyticsService.log("sendMessage failed");
      CrashlyticsService.recordError(e, stack);
    }
  }

  // ---------------- SELECT MSG ----------------
  void startSelection(String msgId) {
    selectionMode.value = true;
    selectedMsgIds.add(msgId);
  }

  void toggleSelection(String msgId) {
    if (selectedMsgIds.contains(msgId)) {
      selectedMsgIds.remove(msgId);
    } else {
      selectedMsgIds.add(msgId);
    }
    if (selectedMsgIds.isEmpty) {
      selectionMode.value = false;
    }
  }

  void clearSelection() {
    selectionMode.value = false;
    selectedMsgIds.clear();
  }

  // ---------------- DELETE SELECTED msg----------------
  Future<void> deleteSelectedMsg() async {
    // delete selected msg
    if (selectedMsgIds.isEmpty) return;

    // Remove from UI
    uiMessages.removeWhere(
      (msg) => selectedMsgIds.contains(
        msg.msgId,
      ), // remove the selected msg id from the uiMessage List
    );

    allMessages.removeWhere((msg) => selectedMsgIds.contains(msg.msgId));

    // Save ids to delete
    final idsToDelete = List<String>.from(selectedMsgIds);

    // Clear selection UI
    clearSelection();

    // Update Firebase in background
    final Map<String, dynamic> updates = {};
    for (final msgId in idsToDelete) {
      updates["messages/$chatId/$msgId/isDeleted"] = true;
    }

    await _db.update(updates);
  }

  //<----   OPEN / CREATE CHAT ----->
  Future<String> openChat({
    required String otherUid,
    required String otherName,
  }) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    // Unique ID pair
    final id = myUid.compareTo(otherUid) < 0
        ? "${myUid}_$otherUid"
        : "${otherUid}_$myUid";

    final chatRoomRef = _db.child("chatRooms/$id");
    final snapshot = await chatRoomRef.get();

    // Create if not exists
    if (!snapshot.exists) {
      final userCtrl = Get.find<AllUsersController>();

      await chatRoomRef.set({
        "chatRoomId": id,
        "otherUid": otherUid,
        "otherName": otherName,
        "isGroup": false,
        "lastUpdated": DateTime.now().millisecondsSinceEpoch,

        "participants": {
          myUid: {"id": myUid, "name": userCtrl.currentUserUsername.value},
          otherUid: {"id": otherUid, "name": otherName},
        },

        "lastMsg": {
          "msgId": "",
          "msgText": "",
          "senderName": "",
          "timeStamp": 0,
        },
      });
    }
    return id;
  }

  // method to reply from notifications
  static Future<void> sendInlineReply({
    required String chatId,
    required String message,
  }) async {
    final userCtrl = Get.find<AllUsersController>();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("messages").child(chatId).push();

    final msgId = ref.key!;
    final time = DateTime.now().millisecondsSinceEpoch;

    await ref.set({
      "msgId": msgId,
      "senderId": user.uid,
      "senderName": userCtrl.currentUserUsername.value, // or fetch from DB
      "text": message,
      "time": time,
      "isDeleted": false,
    });

    // update chatRoom lastMsg
    await FirebaseDatabase.instance.ref("chatRooms/$chatId").update({
      "lastUpdated": time,
      "lastMsg": {
        "msgId": msgId,
        "msgText": message,
        "senderName": userCtrl.currentUserUsername.value,
        "timeStamp": time,
      },
    });
    // increment unread for receiver
    final parts = chatId.split('_');
    final receiverUid = parts.first == user.uid ? parts.last : parts.first;

    await FirebaseDatabase.instance
        .ref("chatRooms/$chatId/unreadCount/$receiverUid")
        .runTransaction((value) {
          final current = (value as int?) ?? 0;
          return Transaction.success(current + 1);
        });
  }

  // ----------------Group functionality-------------
  Future<String> createGroup({
    required String groupName,
    required List<ChatParticipant> members,
  }) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final appCtrl = Get.find<AllUsersController>();
    final groupId = "group_${DateTime.now().millisecondsSinceEpoch}";
    final Map<String, dynamic> participantsMap = {};

    participantsMap[myUid] = {
      "id": myUid,
      "name": appCtrl.currentUserUsername.value,
    };

    for (final user in members) {
      participantsMap[user.id] = user.toMap();
    }

    await _db.child("chatRooms/$groupId").set({
      "chatRoomId": groupId,
      "isGroup": true,
      "groupName": groupName,
      "lastUpdated": DateTime.now().millisecondsSinceEpoch,
      "participants": participantsMap,
      "members": members.map((e) => e.id).toList(),
      "lastMsg": {"msgId": "", "text": "", "senderName": "", "time": 0},
    });
    return groupId;
  }

  void listenGroups() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    _groupSub?.cancel();
    _groupSub = _db.child("chatRooms").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        groups.clear();
        return;
      }

      final List<ChatRoom> list = [];

      data.forEach((key, value) {
        final map = Map<String, dynamic>.from(value);

        // only personal chats for now
        if (map["isGroup"] == true &&
            map["participants"] != null &&
            map["participants"].containsKey(myUid)) {
          final unreadMap = map["unreadCount"] as Map? ?? {};
          final unread = unreadMap[myUid] ?? 0;

          final room = ChatRoom.fromMap(map);
          room.unreadCount = unread;
          list.add(room);
        }
      });

      list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      groups.assignAll(list);
    });
  }

  //----------filter Group -----------
  void _filterGroups() {
    final query = groupSearchQuery.value.toLowerCase();

    if (query.isEmpty) {
      filterGroups.assignAll(groups);
    } else {
      filterGroups.assignAll(
        groups.where((g) => g.groupName.toLowerCase().contains(query)).toList(),
      );
    }
  }

  void onGroupSearchChanged(String value) {
    groupSearchQuery.value = value;
  }

  //<------------ Badge show with count (no. of meg received) ----------->
  /// Increment unread count for a chat
  void incrementUnread(String chatId) {
    final index = groups.indexWhere((chat) => chat.chatRoomId == chatId);

    if (index != -1) {
      groups[index].unreadCount++;
      groups.refresh(); // update UI
    }
  }

  /// Clear unread count when chat is opened
  void clearUnread(String chatId) {
    final index = groups.indexWhere((chat) => chat.chatRoomId == chatId);

    if (index != -1) {
      groups[index].unreadCount = 0;
      groups.refresh();
    }

    // OPTIONAL: persist in Firebase
    _db.child("chatRooms/$chatId/unreadCount").set(0);
  }

  /// fetch fcmToken
  Future<String?> getUserFcmToken(String uid) async {
    if (_fcmCache.containsKey(uid)) {
      return _fcmCache[uid];
    }

    final snapshot = await _db.child("users/$uid/fcmToken").get();
    if (!snapshot.exists) return null;

    final token = snapshot.value.toString();
    _fcmCache[uid] = token;
    return token;
  }

  // in 1-1 reciver chat uid is

  String getReceiverUid() {
    if (chatId == null) {
      throw Exception("chatId not initialized");
    }

    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final parts = chatId!.split('_');
    return parts.first == myUid ? parts.last : parts.first;
  }

  // load history msg
  Future<void> _loadInitialMessages() async {
    final snapshot = await _db.child("messages").child(chatId!).get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map;
    final list = <Message>[];

    data.forEach((key, value) {
      final msg = Message.fromMap(key, value);
      if (!msg.isDeleted) list.add(msg);
    });

    list.sort((a, b) => b.time.compareTo(a.time));
    allMessages.assignAll(list);
    _filterUiMessages();
  }
  // ---------------- CLEANUP ----------------

  @override
  void onClose() {
    if (chatId != null) {
      final myUid = FirebaseAuth.instance.currentUser!.uid;
      _db.child("chatRooms/$chatId/unreadCount/$myUid").set(0);
    }

    isChatOpen = false;
    _msgSub?.cancel();
    _groupSub?.cancel();
    super.onClose();
  }
}

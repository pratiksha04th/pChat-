class ChatRoom {
  final String chatRoomId;
  final List<ChatParticipant> participants;
  final int lastUpdated;
  final bool isGroup;
  final String groupName;
  final LastMessage lastMsg;
  int unreadCount;
  final Map<String,dynamic> deletedFor;



  ChatRoom({
    required this.chatRoomId,
    required this.participants,
    required this.lastUpdated,
    required this.isGroup,
    required this.groupName,
    required this.lastMsg,
    this.unreadCount = 0,
    this.deletedFor = const{},
  });

  String getOtherUserName(String myUid) {
    for (final user in participants) {
      if (user.id != myUid) {
        return user.name;
      }
    }
    return "";
  }

  ChatParticipant? getOtherUser(String myUid) {
    for (final user in participants) {
      if (user.id != myUid) {
        return user;
      }
    }
    return null;
  }

  // Firebase -> Model
  factory ChatRoom.fromMap(Map<dynamic, dynamic> data) {
    final participantsMap = (data['participants'] as Map?) ?? {};

    return ChatRoom(
      chatRoomId: data['chatRoomId'] ?? '',
      participants: participantsMap.values
          .map((e) => ChatParticipant.fromMap(e))
          .toList(),
      lastUpdated: data['lastUpdated'] ?? 0,
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'] ?? '',
      lastMsg: LastMessage.fromMap(
        (data['lastMsg'] as Map?) ?? {},
      ),
      unreadCount: 0,

      deletedFor: data['deletedFor'] != null
          ? Map<String, dynamic>.from(data['deletedFor'])
          : {},
    );
  }

  // Model -> Firebase
  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participants": {
        for (var p in participants) p.id: p.toMap()
      },
      "lastUpdated": lastUpdated,
      "isGroup": isGroup,
      "groupName": groupName,
      "lastMsg": lastMsg.toMap(),
      "unreadCount": unreadCount,
      "deletedFor" : deletedFor ?? {},
    };
  }
}

// ---------------- PARTICIPANT ----------------

class ChatParticipant {
  final String id;
  final String name;

  ChatParticipant({
    required this.id,
    required this.name,
  });

  factory ChatParticipant.fromMap(Map data) {
    return ChatParticipant(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}

// ---------------- LAST MESSAGE ----------------

class LastMessage {
  final String msgId;
  final String text;
  final String senderName;
  final int time;

  LastMessage({
    required this.msgId,
    required this.text,
    required this.senderName,
    required this.time,
  });

  factory LastMessage.fromMap(Map data) {
    return LastMessage(
      msgId: data['msgId'] ?? '',
      text: data['msgText'] ?? '',
      senderName: data['senderName'] ?? '',
      time: data['timeStamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "msgId": msgId,
      "msgText": text,
      "senderName": senderName,
      "timeStamp": time,
    };
  }
}

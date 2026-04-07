enum MessageStatus {
  sending,
  sent,
}

class Message {
  final String msgId;
  final String senderId;
  final String senderName;
  final String text;
  final int time;
  final bool isDeleted;
  final double? lat;
  final double? lang;
  final bool isLocation;
  MessageStatus status;

  Message({
    required this.msgId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isDeleted,
    this.lat,
    this.lang,
    this.isLocation = false,
    this.status = MessageStatus.sent,
  });

  factory Message.fromMap(String id, Map data) {
    return Message(
      msgId: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['msgText'] ?? '',
      time: data['timeStamp'] ?? 0,
      isDeleted: data['isDeleted'] ?? false,
      status: MessageStatus.sent,
    );
  }
}
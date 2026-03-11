class Message {
  final String msgId;
  final String senderId;
  final String senderName;
  final String text;
  final int time;
  final bool isDeleted;

  Message({
    required this.msgId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isDeleted,
  });

  factory Message.fromMap(String id, Map data) {
    return Message(
      msgId: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      time: data['time'] ?? 0,
      isDeleted: data['isDeleted'] ?? false,
    );
  }
}

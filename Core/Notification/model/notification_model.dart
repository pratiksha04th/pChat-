class PushNotificationModel {
  final String token;
  final String title;
  final String body;
  final String type;
  final String conversationTitle;
  final String sender;
  final String message;
  final String chatId;

  PushNotificationModel({
    required this.token,
    required this.title,
    required this.body,
    required this.chatId,
    this.type = 'chat',
    required this.conversationTitle,
    required this.sender,
    required this.message,
  });

  /// Converts model -> FCM HTTP v1 payload
  Map<String, dynamic> toFcmPayload() {
    return {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "type": type,
          "conversationTitle": conversationTitle,
          "sender": sender,
          "message": message,
          "chatId": chatId,
        },
        "android": {
          "priority": "HIGH",
        },
      }
    };
  }
}
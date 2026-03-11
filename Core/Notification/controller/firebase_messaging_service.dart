import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../view/Messaging_notification.dart';
import '../services/notification_service.dart';

/// BACKGROUND HANDLER (TOP-LEVEL ONLY)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.init();

  final data = message.data;

  if (data['type'] != 'chat') return;

  await MessagingNotification.show(
    conversationTitle: data['conversationTitle']?.toString() ?? 'pChat',
    sender: data['sender']?.toString() ?? 'Unknown',
    messages: [data['message']?.toString() ?? ''],
    chatId: data['chatId'],
  );
}

class FirebaseMessagingService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Permission
    await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
    await NotificationService.init();
    // FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    print("FCM DATA RECEIVED: ${message.data}");

    final data = message.data;
    if (data['type'] != 'chat') return;

    final String conversationTitle =
        data['conversationTitle']?.toString() ?? 'pChat';
    final String sender =
        data['sender']?.toString() ?? 'Unknown';
    final String messageText =
        data['message']?.toString() ?? 'New message';

    if (messageText.isEmpty) return;

    MessagingNotification.show(
      conversationTitle: conversationTitle,
      sender: sender,
      messages: [messageText],
      chatId: data['chatId'],
    );
  }
}

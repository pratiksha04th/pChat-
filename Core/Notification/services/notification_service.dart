import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../../Feature/Chat_Screen/controller/chat_controller.dart';
import '../view/Messaging_notification.dart';
import '../../../Feature/Chat_Screen/view/chat_screen.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings,
    onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // CREATE ANDROID NOTIFICATION CHANNEL (REQUIRED)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      MessagingNotification.channelId,
      'Chat Messages',
      description: 'Messaging style notifications',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
// reply from notification
  static void _onNotificationResponse(
      NotificationResponse response) async {
    if (response.actionId != 'reply') return;

    final replyText = response.input?? '';
    final chatId = response.payload;

    //navigate to chatScreen onClick notification
    if (chatId != null && response.actionId == null) {
      Get.to(() =>
          ChatScreen(
            chatId: chatId,
            username: 'Chat',
          ));
    }
    if (replyText.isEmpty || chatId == null) return;

    await ChatController.sendInlineReply(
      chatId: chatId,
      message: replyText,
    );

  }
  static Future<void> showRawNotification({
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    final int notificationId =
    DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

class MessagingNotification {

  static const String channelId = 'messaging_channel_v2';

  static Future<void> show({
    required String conversationTitle,
    required String sender,
    required List<String> messages,
    required String chatId,
  }) async {
    final Person user = Person(name: sender);

    final List<Message> messageList = messages
        .map(
          (text) => Message(
        text,
        DateTime.now(),
        user,
      ),
    )
        .toList();

    final MessagingStyleInformation messagingStyle =
    MessagingStyleInformation(
      user,
      conversationTitle: conversationTitle,
      groupConversation: true,
      messages: messageList,
    );

    /// REPLY ACTION (THIS IS THE KEY PART)
    final AndroidNotificationAction replyAction =
    AndroidNotificationAction(
      'reply', // actionId
      'Reply',
      inputs: const [
        AndroidNotificationActionInput(
          label: 'Type a message',
          allowFreeFormInput: true,
        ),
      ],
      showsUserInterface: true,
      cancelNotification: false,
    );

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      'Chat Messages',
      number: messages.length,
      channelDescription: 'Messaging style notifications',
      channelShowBadge: true,
      styleInformation: messagingStyle,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      actions: [replyAction],
    );

    await NotificationService.showRawNotification(
      title: conversationTitle,
      body: messages.last, // REQUIRED by Android
      details: NotificationDetails(android: androidDetails),
      payload: chatId, // for inline reply
    );
  }
}

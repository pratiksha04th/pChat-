//<-------- USING FIREBASE SEND MESSAGING API ------------->

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/notification_model.dart';
import 'get_server_key.dart';

class SendNotificationService {
  static String _fcmUrl = "https://fcm.googleapis.com/v1/projects/pchat-cc35c/messages:send";

  static Future<void> send({
    required PushNotificationModel notification,
  }) async {
    try {
      final accessToken = await GetServerKey().getServerKeyToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final payload = notification.toFcmPayload();

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("NOTIFICATION SENT");
      } else {
        print("NOTIFICATION FAILED");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
      }
    } catch (e) {
      print("Notification error: $e");
    }
  }
}
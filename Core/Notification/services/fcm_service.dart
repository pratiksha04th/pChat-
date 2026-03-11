import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await FirebaseDatabase.instance
        .ref("users/${user.uid}")
        .update({
      "fcmToken": token,
      "appInstalled": true,
      "lastSeen": ServerValue.timestamp,
    });

    // Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseDatabase.instance
          .ref("users/${user.uid}")
          .update({
        "fcmToken": newToken,
        "appInstalled": true,
      });
    });
  }
}
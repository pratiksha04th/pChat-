//<---------APPLICATION TAKE PERMISSION FROM DEVICE TO USE MICROPHONE ---------------->

import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Opens app settings if user selected "Never allow"
      await openAppSettings();
    }

    return false;
  }
}

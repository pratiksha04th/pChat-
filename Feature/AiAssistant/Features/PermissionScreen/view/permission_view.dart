import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/utilities/App_Colors/App_Colors.dart';
import '../../../../../Core/SharedPreferences/session_manager.dart';
import '../controller/permission_controller.dart';
import '../../CallScreen/view/call_screen.dart';
import '../../../core/widgets/app_bar.dart';

class PermissionView extends StatelessWidget {
  final VoidCallback onAllow;

  const PermissionView({super.key, required this.onAllow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HumeAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.opacityBlue,
              radius: 36,
              child: Icon(Icons.mic_none_outlined,
                  size: 30, color: Colors.black),
            ),
            const SizedBox(height: 24),

            const Text(
              'Microphone access is required',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please enable microphone permissions to start the call.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final permissionController = PermissionController();

                final granted =
                await permissionController.requestMicrophonePermission();

                if (granted) {

                  /// save permission so it won't ask again
                  await SessionManager.setPermissionGiven();

                  /// go directly to call screen
                  Get.off(() => CallScreen(
                    onEndCall: () {
                      Get.back();
                    },
                  ));

                } else {
                  Get.snackbar(
                    "Permission Required",
                    "Microphone permission is needed to start the call",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                "Allow access",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
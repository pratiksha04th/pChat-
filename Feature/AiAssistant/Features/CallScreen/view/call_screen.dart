import 'package:flutter/material.dart';
import 'package:get/get.dart';

///WIDGETS
import '../../../core/widgets/waveform_widget.dart';
import 'package:pchat/Feature/AiAssistant/core/widgets/listening_indicator.dart';

///CONTROLLER
import '../controller/ai_call_controller.dart';

///MODEL
import '../model/chat_message.dart';

class CallScreen extends StatefulWidget {
  final VoidCallback onEndCall;

  const CallScreen({super.key, required this.onEndCall});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AiCallController controller = Get.put(AiCallController());

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    controller.endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            /// CHAT AREA
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (_, i) {
                    return _buildMessage(controller.messages[i]);
                  },
                ),
              ),
            ),

            /// LISTENING INDICATOR
            Obx(() {
              return controller.isListening
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: ListeningIndicator(),
                    )
                  : const SizedBox();
            }),

            /// CONTROLS
            _buildControls(),
          ],
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Text(
            "Hume AI Call",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.formattedTime(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.role == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 18),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Text(
          msg.message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          /// WAVEFORM (only while speaking)
          Obx(() {
            if (!controller.isListening) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WaveformWidget(
                amplitudeStream: controller.micController.amplitudeStream,
              ),
            );
          }),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// MUTE BUTTON
              _roundButton(
                icon: controller.isMuted ? Icons.mic_off : Icons.mic_none,
                active: !controller.isMuted,
                onTap: controller.toggleMute,
              ),

              /// HOLD TO SPEAK BUTTON
              GestureDetector(
                onLongPressStart: (_) => controller.startSpeaking(),
                onLongPressEnd: (_) => controller.stopSpeaking(),
                child: Obx(
                  () => CircleAvatar(
                    radius: 32,
                    backgroundColor: controller.isListening
                        ? Colors.red
                        : Colors.black,
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ),
              ),

              /// SPEAKER BUTTON
              _roundButton(
                icon: controller.speakerOn ? Icons.volume_up : Icons.volume_off,
                active: controller.speakerOn,
                onTap: controller.toggleSpeaker,
              ),

              /// END CALL
              GestureDetector(
                onTap: () {
                  controller.endCall();
                  widget.onEndCall();
                },
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.call_end, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: active ? Colors.black : Colors.grey.shade300,
        child: Icon(icon, color: active ? Colors.white : Colors.black),
      ),
    );
  }
}

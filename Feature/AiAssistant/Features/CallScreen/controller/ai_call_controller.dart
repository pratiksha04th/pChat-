//<----- CONTROLLER FOR AI ASSISTANT ----->
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MODEL
import '../model/chat_message.dart';

/// SERVICES
import '../../../core/services/hume_service.dart';
import '../../../core/services/audio_player_service.dart';

///CONTROLLER
import 'mic_controller.dart';


class AiCallController extends GetxController {
  final HumeService humeService = HumeService();
  final MicController micController = MicController();
  final AudioPlayerService audioPlayerService = AudioPlayerService();

  final messages = <ChatMessage>[].obs;

  var _callActive = false.obs;
  var _isListening = false.obs;
  var _isMuted = false.obs;
  var _speakerOn = true.obs;

  var _callDuration = Duration.zero.obs;

  Timer? _timer;
  StreamSubscription? _micSubscription;

  // ===== GETTERS =====
  bool get isListening => _isListening.value;
  bool get isMuted => _isMuted.value;
  bool get speakerOn => _speakerOn.value;
  Duration get callDuration => _callDuration.value;

  String formattedTime() {
    final minutes =
    _callDuration.value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    _callDuration.value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ===== CALL CONTROL =====

  @override
  void onInit() {
    super.onInit();
    startCall();
  }

  Future<void> startCall() async {
    if (_callActive.value) return;

    _callActive.value = true;
    _callDuration.value = Duration.zero;

    await humeService.connect(onMessage: _handleHumeEvent);
    await micController.init();

    _startTimer();

    debugPrint("Call started");
  }

  Future<void> endCall() async {
    if(!_callActive.value) return;

    _callActive.value = false;

    await _micSubscription?.cancel();
    await micController.dispose();
    await humeService.disconnect();

    _timer?.cancel();

    _isListening.value = false;

    debugPrint("Call ended");
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _callDuration.value =
          _callDuration.value + const Duration(seconds: 1);
    });
  }

  // ===== MIC CONTROL =====

  Future<void> startSpeaking() async {
    if (_isMuted.value || _isListening.value) return;

    debugPrint("User start speaking");

    await audioPlayerService.stop();

    _isListening.value = true;

    micController.startListening();

    _micSubscription?.cancel();

    _micSubscription =
        micController.audioStream.listen((buffer) {
          humeService.sendAudioChunk(buffer);
        });
  }

  Future<void> stopSpeaking() async {

    debugPrint("User released mic");

    _isListening.value = false;

    await _micSubscription?.cancel();
    _micSubscription = null;

    await micController.stopListening();

    await Future.delayed(const Duration(milliseconds: 150));


    humeService.notifyUserFinished();
  }

  void toggleMute() {
    _isMuted.value = !_isMuted.value;

    if (_isMuted.value && _isListening.value) {
      stopSpeaking();
    }

  }

  void toggleSpeaker() {
    _speakerOn.value = !_speakerOn.value;
  }

  // ===== HANDLE HUME EVENTS =====

  void _handleHumeEvent(Map<String, dynamic> data) {

    final type = data["type"];

    debugPrint("Hume event type: $type");

    //ASSISTANT MESSAGE
    if (type == "assistant_message") {

      final text = data["message"]["content"];

      if (text.isNotEmpty) {
        messages.add(ChatMessage(
          role: "assistant",
          message: text,
        ));
      }
    }
    // ASSISTANT AUDIO
    if (type == "audio_output") {

      if(_isListening.value){
        micController.stopListening();
        _isListening.value = false;
      }
      final base64Audio = data["data"];
      final bytes = base64Decode(base64Audio);

      debugPrint("Assistant audio chunk received: ${bytes.length}");

      audioPlayerService.playChunk(bytes);
    }

    // USER MESSAGE
    if (type == "user_message") {
      try {
        final message = data["message"];

        if (message != null && message["content"] != null) {
          final text = message["content"];

          messages.add(ChatMessage(
            role: "user",
            message: text,
          ));

        }
      } catch (e) {
        debugPrint("User message parse error: $e");
      }
    }
  }

  @override
  void onClose(){
    debugPrint("Disposing CallController");

    _timer?.cancel();
    _micSubscription?.cancel();

    micController.dispose();
    humeService.disconnect();
    audioPlayerService.dispose();

    super.onClose();
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// IMPORT FOR WEBSOCKET CONNECTION
import 'package:web_socket_channel/web_socket_channel.dart';


import 'hume_auth_service.dart';
import 'audio_player_service.dart';

class HumeService {
  WebSocketChannel? _channel;
  final AudioPlayerService _audioPlayer = AudioPlayerService();

  bool _connecting = false;
  bool _sessionConfigured = false;

  bool get isConnected => _channel != null;

  Future<void> connect({
    required Function(Map<String, dynamic>) onMessage,
  }) async {
    if (_channel != null || _connecting) return;

    _connecting = true;

    try {
      print("Getting Hume access token...");
      final token = await HumeAuthService.getAccessToken();
      print("Token received");
      final configId = dotenv.env['CONFIG_ID'];
      print("Config ID: $configId");
      _channel = WebSocketChannel.connect(
        Uri.parse(
          "wss://api.hume.ai/v0/evi/chat?access_token=$token&config_id=$configId",
        ),
      );
      await _audioPlayer.init();

      _channel!.stream.listen((message) {
        print("RAW MESSAGE: $message");

        final data = jsonDecode(message);

        if (data['type'] == "error") {
          print("HUME ERROR: $data");
        }
        onMessage(data);
      },
        onDone: () {
          print("Hume WS closed");
          _channel = null;
        },
        onError: (e) {
          print("Hume WS error: $e");
        },
      );

      print("Hume WebSocket Connected with config");

      //Send session settings
      _sendSessionSettings();
    } catch (e) {
      print("Connection error: $e");
    } finally {
      _connecting = false;
    }
  }

  void _sendSessionSettings() {
    if (_channel == null || _sessionConfigured) return;

    _channel!.sink.add(jsonEncode({
      "type": "session_settings",
      "audio": {
        "encoding": "linear16",
        "sample_rate": 16000,
        "channels": 1
      },
      "input_audio_transcription": {
        "enabled" : true
      }
    }));

    _sessionConfigured = true;
    print("Session settings sent");
  }

  /// Correct audio streaming
  void sendAudioChunk(Uint8List buffer) {
    if (_channel == null) {
      debugPrint("Socket not connected yet");
      return;
    }

    _channel!.sink.add(jsonEncode({
      "type": "audio_input",
      "data": base64Encode(buffer),
    }));
  }
  void notifyUserFinished() {
    if (_channel == null) return;

    _channel!.sink.add(jsonEncode({
      "type": "assistant_input_end",
      "text": ""
    }));

    print("User turn committed to Hume");
  }

  void handleAssistantAudio(String base64Audio) {
    try {
      final bytes = base64Decode(base64Audio);
      _audioPlayer.playChunk(bytes);
    } catch(e){
      print(e);
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _sessionConfigured = false;
  }
}
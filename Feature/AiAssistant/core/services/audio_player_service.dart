/// FLUTTER SOUND package is used to record to user voice
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class AudioPlayerService {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _player.openPlayer();
    _initialized = true;
  }

  Future<void> playChunk(Uint8List bytes) async {
    if (!_initialized) {
      await init();
    }

    if (_player.isPlaying) {
      await _player.stopPlayer();
    }

    await _player.startPlayer(
      fromDataBuffer: bytes,
      codec: Codec.pcm16WAV,
    );
  }
  Future<void> stop() async{
    if(!_initialized) return;
    await _player.stopPlayer();
  }

  Future<void> dispose() async {
    await _player.closePlayer();
  }
}
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart';

class MicController {
  static final MicController _instance = MicController._internal();
  factory MicController() => _instance;
  MicController._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final _audioController = StreamController<Uint8List>.broadcast();
  final _amplitudeController = StreamController<double>.broadcast();

  Stream<Uint8List> get audioStream => _audioController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  StreamSubscription<Uint8List>? _audioSubscription;

  bool _initialized = false;
  bool _recording = false;

  Future<void> init() async {
    if (_initialized) return;

    debugPrint("Mic init");

    await _recorder.openRecorder();
    _initialized = true;

    debugPrint("Mic initialized");
  }

//<===== MIC START LISTENING USER VOICE =======>
  Future<void> startListening() async {

    if (!_initialized || _recording) return;
    try {
      debugPrint("START LISTENING");

      if(_recorder.isRecording){
        await _recorder.stopRecorder();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await _recorder.startRecorder(
        codec: Codec.pcm16,
        sampleRate: 16000,
        numChannels: 1,
        bufferSize: 2048,
        enableVoiceProcessing: true,
        toStream: _audioController.sink,
      );

      _recording = true;

      _audioSubscription = _audioController.stream.listen((buffer) {
        _calculateAmplitude(buffer);
      });
    } catch(e, satck){
      print("ERROR: ${e}  STACK: ${satck}");
    }
  }


  //<===== CALCULATE THE AMPLITUDE OF USER VOICE ======>
  void _calculateAmplitude(Uint8List buffer) {
    final data = buffer.buffer.asByteData();

    double sum = 0;

    for (int i = 0; i < buffer.length; i += 2) {
      final sample = data.getInt16(i, Endian.little);
      sum += sample * sample;
    }

    final rms = sqrt(sum / (buffer.length / 2));
    final normalized = (rms / 32768).clamp(0.0, 1.0);

    _amplitudeController.add(normalized);
  }

  //<========= MIC STOP LISTENING USER VOICE =======>
  Future<void> stopListening() async {
    if (!_recording) return;

    debugPrint("STOP LISTENING");

    await _recorder.stopRecorder();

    await Future.delayed(const Duration(milliseconds: 200));

    _amplitudeController.add(0);

    _recording = false;

  }

  //<======= DISPOSE =======>
  Future<void> dispose() async {
    debugPrint("Mic disposed");

    if (_recording) {
      await stopListening();
    }

    await _recorder.closeRecorder();
    await _audioController.close();
    await _amplitudeController.close();
  }
}
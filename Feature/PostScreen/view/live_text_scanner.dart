import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LiveTextScanner extends StatefulWidget {
  const LiveTextScanner({super.key});

  @override
  State<LiveTextScanner> createState() => _LiveTextScannerState();
}

class _LiveTextScannerState extends State<LiveTextScanner> {
  CameraController? _cameraController;
  final TextRecognizer textRecognizer = TextRecognizer();

  bool isProcessing = false;
  bool isStreaming = false;

  String detectedText = "";
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  /// INIT CAMERA
  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    /// Use BACK CAMERA
    final camera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {});

    _startScanning();
  }

  /// START STREAM
  void _startScanning() {
    if (_cameraController == null) return;

    _scanTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) async {
      if (isProcessing || !_cameraController!.value.isInitialized) return;

      isProcessing = true;

      try {
        final file = await _cameraController!.takePicture();

        final inputImage = InputImage.fromFilePath(file.path);

        final recognizedText =
        await textRecognizer.processImage(inputImage);

        if (recognizedText.text.isNotEmpty) {
          detectedText = recognizedText.text;
          setState(() {});
        }
      } catch (e) {
        debugPrint("Scan error: $e");
      }

      isProcessing = false;
    });
  }

  Future<void> _stopCamera() async {
    _scanTimer?.cancel();

    try {
      await _cameraController?.dispose();
    } catch (_) {}
  }
  @override
  void dispose() {
    _stopCamera();
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          /// TEXT OVERLAY
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                detectedText.isEmpty
                    ? "Scanning text..."
                    : detectedText,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          /// USE TEXT BUTTON
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                await _stopCamera();
                Get.back(result: detectedText);
              },
              child: const Text("Use this text"),
            ),
          ),
        ],
      ),
    );
  }
}
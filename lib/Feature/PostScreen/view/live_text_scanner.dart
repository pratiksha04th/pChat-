import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../utilities/App_Strings/app_strings.dart';

class LiveTextScanner extends StatefulWidget {
  const LiveTextScanner({super.key});

  @override
  State<LiveTextScanner> createState() => _LiveTextScannerState();
}

class _LiveTextScannerState extends State<LiveTextScanner> {
  CameraController? _cameraController;

  final TextRecognizer _textRecognizer = TextRecognizer();

  RecognizedText? recognizedText;

  bool isProcessing = false;
  bool isInitialized = false;

  Size? imageSize;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  /// INIT CAMERA
  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();

    await _cameraController!.startImageStream(_processCameraFrame);

    if (!mounted) return;

    setState(() {
      isInitialized = true;
    });
  }

  /// PROCESS LIVE FRAME
  Future<void> _processCameraFrame(CameraImage image) async {
    if (isProcessing) return;

    isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);

      final result = await _textRecognizer.processImage(inputImage);

      setState(() {
        recognizedText = result;
        imageSize = Size(image.width.toDouble(), image.height.toDouble());
      });
    } catch (e) {
      debugPrint("OCR ERROR: $e");
    }

    await Future.delayed(const Duration(milliseconds: 250));

    isProcessing = false;
  }

  /// CONVERT CAMERA IMAGE TO INPUT IMAGE
  InputImage _inputImageFromCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// CAPTURE IMAGE
  Future<void> _captureFrame() async {
    try {
      await _cameraController?.stopImageStream();

      final file = await _cameraController!.takePicture();

      Get.back(result: File(file.path));
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToCaptureImage);
    }
  }

  @override
  void dispose() {
    if (_cameraController?.value.isStreamingImages ?? false) {
      _cameraController?.stopImageStream();
    }

    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA PREVIEW
          SizedBox.expand(child: CameraPreview(_cameraController!)),

          /// LIVE OCR BOXES
          if (recognizedText != null && imageSize != null)
            CustomPaint(
              painter: LiveTextPainter(
                recognizedText: recognizedText!,
                imageSize: imageSize!,
              ),
              child: Container(),
            ),

          /// DARK OVERLAY
          IgnorePointer(child: Container(color: Colors.black.withOpacity(.25))),

          /// TOP TEXT
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: const [
                Text(
                  AppStrings.pointCameraAtText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppStrings.textWillBeDetectedAutomatically,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// CAPTURE BUTTON
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureFrame,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTextPainter extends CustomPainter {
  final RecognizedText recognizedText;
  final Size imageSize;

  LiveTextPainter({required this.recognizedText, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.height;
    final scaleY = size.height / imageSize.width;

    final paint = Paint()
      ..color = Colors.yellow.withOpacity(.35)
      ..style = PaintingStyle.fill;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final rect = element.boundingBox;

          final scaledRect = Rect.fromLTRB(
            rect.left * scaleX,
            rect.top * scaleY,
            rect.right * scaleX,
            rect.bottom * scaleY,
          );

          canvas.drawRect(scaledRect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

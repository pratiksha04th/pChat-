import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../utilities/App_Strings/app_strings.dart';
import 'selection_painter.dart';
import 'text_painter_overlay.dart';

class TextPreviewScreen extends StatefulWidget {
  final File imageFile;

  const TextPreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends State<TextPreviewScreen> {
  final TextRecognizer textRecognizer = TextRecognizer();

  RecognizedText? recognizedText;
  Size? imageSize;

  Rect selectionRect = const Rect.fromLTWH(
    50,
    100,
    250,
    200,
  );

  String resizeMode = "";

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  /// PROCESS text recognization
  Future<void> _processImage() async {
    final inputImage = InputImage.fromFile(widget.imageFile);

    final result =
    await textRecognizer.processImage(inputImage);

    final decodedImage = await decodeImageFromList(
      await widget.imageFile.readAsBytes(),
    );

    setState(() {
      recognizedText = result;

      imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );
    });
  }

  /// GET TEXT INSIDE SELECTION FRAME
  String getTextInsideFrame() {
    if (recognizedText == null || imageSize == null) return "";

    final screenSize = MediaQuery.of(context).size;

    final imageAspect = imageSize!.width / imageSize!.height;
    final screenAspect = screenSize.width / screenSize.height;

    double displayWidth;
    double displayHeight;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspect > screenAspect) {
      displayWidth = screenSize.width;
      displayHeight = displayWidth / imageAspect;
      offsetY = (screenSize.height - displayHeight) / 2;
    } else {
      displayHeight = screenSize.height;
      displayWidth = displayHeight * imageAspect;
      offsetX = (screenSize.width - displayWidth) / 2;
    }

    final scaleX = displayWidth / imageSize!.width;
    final scaleY = displayHeight / imageSize!.height;

    List<String> selectedWords = [];

    for (final block in recognizedText!.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;

          final transformedRect = Rect.fromLTRB(
            box.left * scaleX + offsetX,
            box.top * scaleY + offsetY,
            box.right * scaleX + offsetX,
            box.bottom * scaleY + offsetY,
          );

          if (selectionRect.overlaps(transformedRect)) {
            selectedWords.add("${element.text} ");
          }
        }
      }
    }

    return selectedWords.join(" ").trim();
  }

  /// DETECT DRAG MODE
  String _getResizeMode(Offset position) {
    const threshold = 30;

    if ((position - selectionRect.topLeft).distance <
        threshold) {
      return "tl";
    }

    if ((position - selectionRect.topRight).distance <
        threshold) {
      return "tr";
    }

    if ((position - selectionRect.bottomLeft).distance <
        threshold) {
      return "bl";
    }

    if ((position - selectionRect.bottomRight).distance <
        threshold) {
      return "br";
    }

    if (selectionRect.contains(position)) {
      return "move";
    }

    return "";
  }

  /// UPDATE FRAME
  void _updateRect(DragUpdateDetails details) {
    Rect newRect = selectionRect;

    switch (resizeMode) {
      case "move":
        newRect =
            selectionRect.shift(details.delta);
        break;

      case "tl":
        newRect = Rect.fromLTRB(
          selectionRect.left + details.delta.dx,
          selectionRect.top + details.delta.dy,
          selectionRect.right,
          selectionRect.bottom,
        );
        break;

      case "tr":
        newRect = Rect.fromLTRB(
          selectionRect.left,
          selectionRect.top + details.delta.dy,
          selectionRect.right + details.delta.dx,
          selectionRect.bottom,
        );
        break;

      case "bl":
        newRect = Rect.fromLTRB(
          selectionRect.left + details.delta.dx,
          selectionRect.top,
          selectionRect.right,
          selectionRect.bottom + details.delta.dy,
        );
        break;

      case "br":
        newRect = Rect.fromLTRB(
          selectionRect.left,
          selectionRect.top,
          selectionRect.right + details.delta.dx,
          selectionRect.bottom + details.delta.dy,
        );
        break;
    }

    final screenSize =
        MediaQuery.of(context).size;

    newRect = newRect.intersect(
      Rect.fromLTWH(
        0,
        0,
        screenSize.width,
        screenSize.height,
      ),
    );

    if (newRect.width < 80 ||
        newRect.height < 80) return;

    setState(() {
      selectionRect = newRect;
    });
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        recognizedText == null || imageSize == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanStart: (details) {
          resizeMode =
              _getResizeMode(details.localPosition);
        },
        onPanUpdate: _updateRect,
        child: Stack(
          children: [
            if (loading)
              const Center(
                child:
                CircularProgressIndicator(),
              )
            else
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// IMAGE
                    Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                    ),

                    /// TEXT HIGHLIGHT
                    CustomPaint(
                      painter: LensTextPainter(
                        recognizedText!,
                        imageSize!,
                        selectionRect,
                      ),
                    ),

                    /// SELECTION FRAME
                    CustomPaint(
                      painter: SelectionPainter(
                        selectionRect,
                      ),
                    ),
                  ],
                ),
              ),

            /// BUTTON
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  final text =
                  getTextInsideFrame();

                  Get.back(
                    result: text,
                  );
                },
                child: const Text(
                  AppStrings.useSelectedArea
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
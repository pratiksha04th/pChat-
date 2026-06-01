import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LensTextPainter extends CustomPainter {
  final RecognizedText recognizedText;
  final Size imageSize;
  final Rect selectionRect;

  LensTextPainter(
      this.recognizedText,
      this.imageSize,
      this.selectionRect,
      );

  @override
  void paint(Canvas canvas, Size size) {
    /// IMAGE / SCREEN ASPECT
    final imageAspect =
        imageSize.width / imageSize.height;

    final screenAspect =
        size.width / size.height;

    double displayWidth;
    double displayHeight;

    double offsetX = 0;
    double offsetY = 0;

    /// CALCULATE FIT.CONTAIN AREA
    if (imageAspect > screenAspect) {
      displayWidth = size.width;
      displayHeight =
          displayWidth / imageAspect;

      offsetY =
          (size.height - displayHeight) / 2;
    } else {
      displayHeight = size.height;
      displayWidth =
          displayHeight * imageAspect;

      offsetX =
          (size.width - displayWidth) / 2;
    }

    /// SCALE FACTORS
    final scaleX =
        displayWidth / imageSize.width;

    final scaleY =
        displayHeight / imageSize.height;

    /// HIGHLIGHT STYLE
    final fillPaint = Paint()
      ..color = Colors.yellow.withOpacity(.30)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    /// DRAW OCR BOXES
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;

          final transformedRect =
          Rect.fromLTRB(
            box.left * scaleX + offsetX,
            box.top * scaleY + offsetY,
            box.right * scaleX + offsetX,
            box.bottom * scaleY + offsetY,
          );

          /// ONLY DRAW IF CENTER INSIDE FRAME
          if (selectionRect.contains(
              transformedRect.center)) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                transformedRect,
                const Radius.circular(4),
              ),
              fillPaint,
            );

            canvas.drawRRect(
              RRect.fromRectAndRadius(
                transformedRect,
                const Radius.circular(4),
              ),
              borderPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {
    return true;
  }
}
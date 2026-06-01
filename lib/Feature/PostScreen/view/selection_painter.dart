import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../utilities/App_Colors/App_Colors.dart';

class SelectionPainter extends CustomPainter {
  final Rect rect;

  SelectionPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    /// MAIN BORDER
    final borderPaint = Paint()
      ..color = AppColors.themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    /// GLOW EFFECT
    final glowPaint = Paint()
      ..color = AppColors.themeColor.withOpacity(.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    /// DRAW GLOW
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(14),
      ),
      glowPaint,
    );

    /// DRAW MAIN BORDER
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(14),
      ),
      borderPaint,
    );

    /// CORNER BRACKET STYLE
    final cornerPaint = Paint()
      ..color = AppColors.themeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 28;

    /// TOP LEFT
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );

    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(0, cornerLength),
      cornerPaint,
    );

    /// TOP RIGHT
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );

    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, cornerLength),
      cornerPaint,
    );

    /// BOTTOM LEFT
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );

    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -cornerLength),
      cornerPaint,
    );

    /// BOTTOM RIGHT
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );

    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';

class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isMe;

  ChatBubbleClipper({required this.isMe});

  @override
  Path getClip(Size size) {
    final path = Path();

    const radius = 16.0;
    const tailSize = 6.0;

    if (isMe) {
      // RIGHT SIDE SENDER)
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);

      path.lineTo(size.width, size.height - radius - tailSize);
      path.quadraticBezierTo(
          size.width, size.height - tailSize, size.width - radius, size.height - tailSize);

      // tail
      path.lineTo(size.width - 10, size.height - tailSize);
      path.quadraticBezierTo(
          size.width, size.height, size.width - 2, size.height);

      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);

      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    } else {
      // LEFT SIDE (RECEIVER)
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);

      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

      path.lineTo(12, size.height);

      // tail
      path.quadraticBezierTo(0, size.height, 2, size.height - tailSize);
      path.quadraticBezierTo(0, size.height - tailSize, 8, size.height - tailSize);

      path.lineTo(radius, size.height - tailSize);
      path.quadraticBezierTo(0, size.height - tailSize, 0, size.height - radius - tailSize);

      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
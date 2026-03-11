import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static Color themeColor = Color(0xFF1F78C8);
  static Color splashBgColor1 = Color(0xFF3AA0F3);
  static Color splashBgColor = Color(0xFFF4F6F8);
  static Color redColor = Color(0xFFFF3B3B);
  static Color opacityBlue = themeColor.withOpacity(0.1);

  static LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90E2), Color(0xFFFFB6D5), Color(0xFFE3F2FD)],
    stops: [0.0, 0.5, 1.0],
  );
}

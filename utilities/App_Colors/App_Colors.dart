import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static Color themeColor = Color(0xFF1F78C8);
  static Color splashBgColor = Color(0xFFF4F6F8);
  static Color redColor = Color(0xFFFF3B3B);
  static Color opacityBlue = themeColor.withOpacity(0.1);

  static LinearGradient darkAvatarGradient = LinearGradient(
    colors: [
      AppColors.themeColor,
      AppColors.themeColor.withOpacity(0.7),
    ],
  );

  static LinearGradient lightAvatarGradient =LinearGradient(
    colors: [
      Colors.white.withOpacity(0.95),
      Colors.blue.shade50.withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

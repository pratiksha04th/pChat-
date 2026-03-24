import 'package:flutter/material.dart';
import '../../../utilities/App_Colors/App_Colors.dart';

class AppInputDecoration {
  static InputDecoration build({
    required String hint,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.grey.shade700,
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.grey.shade500,
      fontSize: 14,
      ),
      labelText: label,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.themeColor,
      ),
      filled: true,
      fillColor: Colors.blue.shade100.withOpacity(0.2),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.themeColor,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width :1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

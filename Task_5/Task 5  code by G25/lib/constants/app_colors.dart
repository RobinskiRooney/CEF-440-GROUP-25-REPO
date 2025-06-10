// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF007BFF); // A vibrant blue
  static const Color secondaryColor = Color(0xFF007BFF); // Same as primary for download button
   static const Color accentColor = Color(0xFFFFC107); // A shade of amber/ye
  // static const Color backgroundColor = Color(0xFFFFFFFF); // White background
  static const Color cardColor = Color(0xFFFFFFFF); // White card background
  // static const Color textColor = Color(0xFF333333); // Dark grey for general text
  // static const Color greyTextColor = Color(0xFF888888); // Lighter grey for secondary text
  static const Color greyButtonColor = Color(0xFFE0E0E0); // Light grey for scan again button
  // static const Color lightGrey = Color(0xFFF0F0F0); // Very light grey for placeholders
    static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey background
  static const Color textColor = Color(0xFF212121); // Dark grey/black for general text
  static const Color greyTextColor = Color(0xFF757575); // Lighter grey for secondary text
  static const Color lightGrey = Color(0xFFEEEEEE); // Very light grey for backgrounds/borders
  static const Color errorColor = Color(0xFFD32F2F); // Red for errors
  static const Color successColor = Color(0xFF388E3C); // Green for su

  // Specific colors for the dashboard page
  static const Color lightBlueGradientStart = Color(0xFF81D4FA); // Lighter blue for header gradient
  static const Color blueGradientEnd = Color(0xFF2196F3); // Darker blue for header gradient
  static const Color lightBlueCard = Color(0xFFE3F2FD); // Light blue for diagnosis card
  static const Color lightOrangeCard = Color(0xFFFBE9E7); // Light red/orange for diagnosis card


  // For primary swatch to generate different shades of the primary color
  static const MaterialColor primaryMaterialColor = MaterialColor(
    0xFF007BFF,
    <int, Color>{
      50: Color(0xFFE0F2FF),
      100: Color(0xFFB3DAFF),
      200: Color(0xFF80C2FF),
      300: Color(0xFF4DAAFF),
      400: Color(0xFF2698FF),
      500: Color(0xFF007BFF),
      600: Color(0xFF0070E6),
      700: Color(0xFF0061CC),
      800: Color(0xFF0052B3),
      900: Color(0xFF003F80),
    },
  );
}
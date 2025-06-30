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
  //   static const Color primaryColor = Color(0xFF3182CE); // Dark Blue
  static const Color primaryDark = Color(0xFF1E3A5F); // Even darker blue for header backgrounds
  // static const Color accentColor = Color(0xFFF6AD55); // Orange/Yellow accent
  // static const Color successColor = Color(0xFF48BB78); // Green for success/positive
  // static const Color errorColor = Color(0xFFE53E3E);   // Red for errors
  static const Color warningColor = Color(0xFFF6AD55); // Orange for warnings

  // static const Color textColor = Color(0xFF2D3748);    // Dark grey for main text
  static const Color secondaryTextColor = Color(0xFF718096); // Lighter grey for secondary text
  static const Color borderColor = Color(0xFFE2E8F0);  // Light grey for borders
  static const Color inputFillColor = Color(0xFFF7FAFC); // Very light grey for input fields
  // static const Color backgroundColor = Color(0xFFF8F8F8); // Light background for general use


  // Specific colors for the dashboard page
  static const Color lightBlueGradientStart = Color(0xFF81D4FA); // Lighter blue for header gradient
  static const Color blueGradientEnd = Color(0xFF2196F3); // Darker blue for header gradient
  static const Color lightBlueCard = Color(0xFFE3F2FD); // Light blue for diagnosis card
  static const Color lightOrangeCard = Color(0xFFFBE9E7); // Light red/orange for diagnosis card
  //   static const Color primaryColor = Color(0xFF1E40AF); // Deep Blue (as specified)
  // static const Color accentColor = Color(0xFFFFC107); // Amber/Yellow
  // static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey Background
  // static const Color textColor = Color(0xFF212121); // Dark Grey/Black
  // static const Color greyTextColor = Color(0xFF757575); // Medium Grey
  // static const Color lightGrey = Color(0xFFEEEEEE); // Very Light Grey
  static const Color chipColor = Color(0xFFE0E0E0); // Lighter grey for chips
  static const Color redLogout = Color(0xFFE53935); // Red for logout button
  static const Color greenStatus = Color(0xFF4CAF50); // Green for available
  static const Color orangeStatus = Color(0xFFFB8C00); // Orange for closed/busy

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





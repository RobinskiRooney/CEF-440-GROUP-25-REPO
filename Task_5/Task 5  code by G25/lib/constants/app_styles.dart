// lib/constants/app_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.greyTextColor,
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle navBarLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headline4 = TextStyle( // Added for smaller headlines
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );


  static const TextStyle smallText = TextStyle( // Added for smaller descriptive text
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );


}

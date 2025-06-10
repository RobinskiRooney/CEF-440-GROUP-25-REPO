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
  
  //  static const TextStyle bodyText2 = TextStyle( // Added for smaller descriptive text
  //   fontSize: 14,
  //   fontWeight: FontWeight.normal,
  //   color: AppColors.textColor,
  // );

    // Body Text
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryTextColor,
  );

  // // Button Text
  // static const TextStyle buttonText = TextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w600,
  //   color: Colors.white, // Default for ElevatedButton
  // );

  // Input Field Styles
  static const TextStyle labelText = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryTextColor,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryTextColor,
  );

  // // Small Text / Captions
  // static const TextStyle smallText = TextStyle(
  //   fontSize: 12,
  //   color: AppColors.secondaryTextColor,
  // );

  // Error Text
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: AppColors.errorColor,
    fontWeight: FontWeight.bold,
  );

  // Success Text
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    color: AppColors.successColor,
    fontWeight: FontWeight.bold,
  );
  

  // static const TextStyle headline4 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  // static const TextStyle bodyText = TextStyle(fontSize: 14);
  // static const TextStyle smallText = TextStyle(fontSize: 12);
  // static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle chipText = TextStyle(fontSize: 10, color: AppColors.textColor);
  static const TextStyle profileName = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textColor);
  static const TextStyle profileEmail = TextStyle(fontSize: 16, color: AppColors.greyTextColor);
  static const TextStyle statNumber = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor);
  static const TextStyle statLabel = TextStyle(fontSize: 12, color: AppColors.greyTextColor);
  static const TextStyle menuTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textColor);
}

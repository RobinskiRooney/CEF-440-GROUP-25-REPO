// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Added validator for TextFormField
  final bool readOnly; // Added readOnly property
  final int? maxLines; // Added maxLines for multiline input
  final int? minLines; // Added minLines for multiline input

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.validator, // Initialize validator
    this.readOnly = false, // Initialize readOnly
    this.maxLines = 1, // Default to single line
    this.minLines, // Allow null for flexible multiline
  });

  @override
  Widget build(BuildContext context) {
    // Using TextFormField directly for built-in validation support
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      readOnly: readOnly, // Apply readOnly property
      maxLines: maxLines, // Apply maxLines property
      minLines: minLines, // Apply minLines property
      validator: validator, // Apply validator function
      style: AppStyles.bodyText1.copyWith(color: AppColors.textColor), // Consistent text style

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.bodyText2, // Use AppStyles for hint text style
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.secondaryTextColor, // Use AppColors for consistent icon color
          size: 20,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.secondaryTextColor, // Use AppColors for consistent icon color
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.inputFillColor, // Use AppColors for fill color
        border: OutlineInputBorder( // Default border style
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border when filled, as per default
        ),
        enabledBorder: OutlineInputBorder( // Border when enabled
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor, width: 1.0), // Use AppColors for border color
        ),
        focusedBorder: OutlineInputBorder( // Border when focused
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0), // Use AppColors for focused border
        ),
        errorBorder: OutlineInputBorder( // Border for validation errors
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0), // Use AppColors for error border
        ),
        focusedErrorBorder: OutlineInputBorder( // Border for validation errors when focused
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0), // Use AppColors for focused error border
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

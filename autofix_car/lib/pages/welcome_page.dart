// lib/screens/welcome_page.dart
import 'package:autofix_car/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'login_page.dart'; // Assuming you will have a login page
import 'register_page.dart'; // Assuming you will have a register page

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // For dark status bar icons on light background
        leading: IconButton( // ADDED: Back button
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
                              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()), // Assuming RegisterPage exists
                  );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2), // Pushes content towards the center/top

              // App Logo (Placeholder - replace with your actual logo asset)
              Image.asset(
                'assets/icons/logo.png', // Replace with your actual logo path
                height: 100,
                width: 100,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found
                  return Icon(
                    Icons.car_repair,
                    size: 100,
                    color: AppColors.primaryColor,
                  );
                },
              ),
              const SizedBox(height: 20),

              // App Name
              Text(
                'AutoFix car',
                style: AppStyles.headline1.copyWith(color: AppColors.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Tagline
              Text(
                'Diagnose your car fault with peace of mind.',
                style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3), // Pushes buttons towards the bottom

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Login Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()), // Assuming LoginPage exists
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size.fromHeight(50), // Full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Login',
                  style: AppStyles.buttonText,
                ),
              ),
              const SizedBox(height: 16),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  // Navigate to Register Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()), // Assuming RegisterPage exists
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor, // Text color
                  side: const BorderSide(color: AppColors.primaryColor, width: 2), // Border color and width
                  minimumSize: const Size.fromHeight(50), // Full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  elevation: 0, // No shadow for outlined button
                ),
                child: Text(
                  'Register',
                  style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor),
                ),
              ),
              const Spacer(flex: 1), // Small space at the very bottom
            ],
          ),
        ),
      ),
    );
  }
}
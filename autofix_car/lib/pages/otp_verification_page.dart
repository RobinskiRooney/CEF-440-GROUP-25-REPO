// lib/screens/otp_verification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'home_page.dart'; // Import the HomePage

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < _otpControllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus(); // Unfocus last field
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Method to show success message and navigate
  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP Verified Successfully!',
          style: AppStyles.buttonText.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green, // Green for success
        duration: const Duration(seconds: 3), // Show for 3 seconds
      ),
    );

    // Navigate to HomePage after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) { // Check if the widget is still in the tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor, // White background for AppBar
      elevation: 0, // No shadow
      systemOverlayStyle: SystemUiOverlayStyle.dark, // For dark status bar icons
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () {
          Navigator.pop(context); // Navigate back
        },
      ),
      title: const Text(
        'OTP Verification',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'OTP Verification',
                style: AppStyles.headline2.copyWith(color: AppColors.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Enter the OTP sent to +237 659 658 507',
                style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppStyles.headline1.copyWith(color: AppColors.textColor),
                      decoration: InputDecoration(
                        counterText: "", // Hide character counter
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.lightGrey, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.lightGrey,
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't receive the OTP?",
                    style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle resend OTP logic
                      print('Resend OTP pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resending OTP...')),
                      );
                    },
                    child: Text(
                      'RESEND OTP',
                      style: AppStyles.bodyText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(), // Pushes content to the top and bottom
              ElevatedButton(
                onPressed: () {
                  String otp = _getOtp();
                  print('Entered OTP: $otp');
                  // For demonstration, we'll assume OTP is always "successful"
                  // In a real app, you would verify the OTP with a backend here.
                  _showSuccessAndNavigate();
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
                  'VERIFY & PROCEED',
                  style: AppStyles.buttonText,
                ),
              ),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

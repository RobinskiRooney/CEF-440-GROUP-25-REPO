import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/otp_verification_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // For dark status bar icons
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (e.g., login)
          },
        ),
        title: const Text(
          'Forgot Password', // Title for the page
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Dashboard Image (as seen in the design)
            Image.asset(
              'assets/images/d2.jpeg', // Ensure this image is in your assets
              fit: BoxFit.cover,
            ),

            
            const SizedBox(height: 30),
            // "AutoFix car" text
            const Text(
              'AutoFix car',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Subtitle
            const Text(
              "You don't remember your password? change it",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Password Reset Card
            _buildResetPasswordCard(context),
            const SizedBox(height: 50), // Spacing at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildResetPasswordCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card fit its content
        children: [
          // Email input field
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Value',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none, // Remove default border
              ),
              filled: true,
              fillColor: Colors.grey.shade100, // Light grey fill
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 30),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the end
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Typically go back to login
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  // Implement password reset logic here
     
             Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OtpVerificationPage()),
    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87, // Dark button color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
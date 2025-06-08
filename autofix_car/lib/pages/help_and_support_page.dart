// lib/screens/help_and_support_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  // AppBar builder method for this specific page
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Blue background for AppBar
      elevation: 0, // No shadow
      systemOverlayStyle: SystemUiOverlayStyle.light, // For white status bar icons
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          // Navigate back to the previous screen
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Help and Support',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Handle notification button press
            print('Notification button pressed on Help and Support page');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // Use the custom AppBar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FAQs',
                style: AppStyles.headline2.copyWith(color: AppColors.textColor),
              ),
              const SizedBox(height: 20),
              // FAQ Item 1
              _buildFaqCard(
                context,
                question: '1. Why is the app not scanning',
                answer: 'If you are encountering problems while scanning your dashboard, please ensure good lighting, a steady hand, and that the dashboard is within the designated scanning frame. Also, check your device\'s camera permissions for the app.',
              ),
              const SizedBox(height: 15),
              // FAQ Item 2
              _buildFaqCard(
                context,
                question: '2. Why is the app not scanning',
                answer: 'If you are encountering problems while scanning your dashboard, please ensure good lighting, a steady hand, and that the dashboard is within the designated scanning frame. Also, check your device\'s camera permissions for the app.',
              ),
              const SizedBox(height: 15),
              // FAQ Item 3
              _buildFaqCard(
                context,
                question: '3. Why is the app not scanning',
                answer: 'If you are encountering problems while scanning your dashboard, please ensure good lighting, a steady hand, and that the dashboard is within the designated scanning frame. Also, check your device\'s camera permissions for the app.',
              ),
              const SizedBox(height: 15),
              // You can add more FAQ items here following the same pattern

              const SizedBox(height: 30), // Spacing before the next section
              Text(
                'Tips',
                style: AppStyles.headline2.copyWith(color: AppColors.textColor),
              ),
              const SizedBox(height: 20),
              // Tip Item 1
              _buildTipCard(
                context,
                title: 'Maintain your car regularly',
                description: 'Regular maintenance can prevent many common car problems and extend the life of your vehicle. Follow your manufacturer\'s recommended service schedule.',
              ),
              const SizedBox(height: 15),
              // Tip Item 2
              _buildTipCard(
                context,
                title: 'Check tire pressure weekly',
                description: 'Proper tire pressure is crucial for safety, fuel efficiency, and tire longevity. Check it weekly and inflate to the recommended PSI.',
              ),
              const SizedBox(height: 15),
              // Tip Item 3
              _buildTipCard(
                context,
                title: 'Understand dashboard warning lights',
                description: 'Familiarize yourself with the meaning of common dashboard warning lights. Ignoring them can lead to serious and costly repairs.',
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, {required String question, required String answer}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardColor,
      child: ExpansionTile(
        title: Text(
          question,
          style: AppStyles.headline3.copyWith(color: AppColors.textColor),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right, color: AppColors.greyTextColor),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(
              answer,
              style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
            ),
          ),
        ],
        onExpansionChanged: (bool expanded) {
          // You can add logic here if you want to do something when the tile expands/collapses
        },
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, {required String title, required String description}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.headline3.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

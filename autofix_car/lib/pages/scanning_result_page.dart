import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'dart:io'; // For File (to display captured image)
import '../widgets/scan_item_card.dart';
import '../models/scan_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/camera_overlay_scanner.dart';
// import '../pages/main_navigation.dart'; // No longer importing directly, assuming BottomNavBar covers it

class ScanningResultPage extends StatelessWidget {
  final String? capturedImagePath; // Field to hold the captured image path

  const ScanningResultPage({
    super.key,
    this.capturedImagePath, // Make it optional
  });

  // Mock data for previous scans
  final List<ScanData> previousScans = const [
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG', // Placeholder image
      title: 'Power steering problem',
      description: 'imminent problems with the power steering system.',
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG',
      title: 'Power steering problem',
      description: 'imminent problems with the power steering system.',
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG',
      title: 'Power steering problem',
      description: 'imminent problems with the power steering system.',
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG',
      title: 'Power steering problem',
      description: 'imminent problems with the power steering system.',
    ),
  ];

  // AppBar builder method
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () {
          // You might navigate back to the camera or a different main tab
          print('Back button pressed on Scanning Result Page');
          // Example: Navigator.pop(context); if there's a previous route to pop to
          // If this is the main entry after camera, consider pushing to a main dashboard
        },
      ),
      title: const Text(
        'Scanning Result', // Changed title to 'Scanning Result'
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            // Handle notification button press
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Added the custom AppBar
      body: SafeArea(
        child: Column(
          children: [
            // Top section: Display captured image or placeholder
            Expanded(
              flex: 2, // Takes more space
              child: Container(
                color: AppColors.lightGrey, // Default placeholder color
                alignment: Alignment.center,
                child: capturedImagePath != null && File(capturedImagePath!).existsSync()
                    ? Image.file(
                        File(capturedImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Could not load image.',
                              style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                            ),
                          );
                        },
                      )
                    : Text(
                        'Video/Image Area',
                        style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                      ),
              ),
            ),
            // Consult a mechanic button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle consult mechanic
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
                  'Consult a mechanic',
                  style: AppStyles.buttonText,
                ),
              ),
            ),
            // Scan Again and Download buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle scan again - maybe navigate back to camera
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraOverlayScanner()));
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.textColor),
                      label: Text('Scan Again', style: AppStyles.buttonText.copyWith(color: AppColors.textColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greyButtonColor,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle download
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: Text('Download', style: AppStyles.buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Previous Scans header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Previous Scans',
                  style: AppStyles.headline2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // List of previous scans
            Expanded(
              flex: 3, // Takes more space than the top section
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: previousScans.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ScanItemCard(scan: previousScans[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}


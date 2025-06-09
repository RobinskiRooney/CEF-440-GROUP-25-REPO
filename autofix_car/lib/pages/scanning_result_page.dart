// lib/pages/scanning_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'dart:io'; // For File (to display captured image)
import 'package:flutter/foundation.dart'; // For debugPrint

import '../widgets/scan_item_card.dart'; // Import the new ScanItemCard
import '../models/scan_data.dart'; // Import the new ScanData model
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles
import '../widgets/camera_overlay_scanner.dart'; // Import CameraOverlayScanner (the simulated camera page)
// import '../pages/main_navigation.dart'; // No longer importing directly, assuming BottomNavBar covers it

class ScanningResultPage extends StatelessWidget {
  final String? capturedImagePath; // Field to hold the captured image path

  const ScanningResultPage({
    super.key,
    this.capturedImagePath, // Make it optional
  });

  // Mock data for previous scans
  // In a real app, this would be fetched from your backend
  final List<ScanData> previousScans = const [
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG1', // Placeholder image
      title: 'Power steering problem',
      description: 'Potential issues with the power steering system detected. Check fluid level and pump.',
      status: 'Faults Detected',
      scanDateTime: null, // Will use current date if null
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG2',
      title: 'Tire Pressure Warning',
      description: 'One or more tires are underinflated. Check tire pressure and inflate to recommended PSI.',
      status: 'Needs Attention',
      scanDateTime: null,
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG3',
      title: 'Engine Oil Low',
      description: 'Engine oil level is low. Top up engine oil immediately to prevent damage.',
      status: 'Faults Detected',
      scanDateTime: null,
    ),
    ScanData(
      imagePath: 'https://placehold.co/60x60/F0F0F0/000000?text=IMG4',
      title: 'No Issues Detected',
      description: 'No significant faults or warnings found during the scan.',
      status: 'No Faults',
      scanDateTime: null,
    ),
  ];

  // AppBar builder method
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () {
          // You might navigate back to the camera or a different main tab
          debugPrint('Back button pressed on Scanning Result Page');
          Navigator.pop(context); // Pops to previous page, usually CameraOverlayScanner
        },
      ),
      title: Text(
        'Scanning Result',
        style: AppStyles.bodyText1.copyWith(
          color: AppColors.textColor, // Using AppColors.textColor
          fontWeight: FontWeight.w600, // Adjusted weight
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications (Not Implemented)')),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // Pass context to AppBar builder
      body: SafeArea(
        child: Column(
          children: [
            // Top section: Display captured image or placeholder
            Expanded(
              flex: 2, // Takes more space
              child: Container(
                color: AppColors.inputFillColor, // Using a consistent color from AppColors
                alignment: Alignment.center,
                child: capturedImagePath != null && File(capturedImagePath!).existsSync()
                    ? Image.file(
                        File(capturedImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading captured image: $error'); // Use debugPrint
                          return Center(
                            child: Text(
                              'Could not load image.',
                              style: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor), // Consistent style
                            ),
                          );
                        },
                      )
                    : Text(
                        'Video/Image Area',
                        style: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor), // Consistent style
                      ),
              ),
            ),
            // Consult a mechanic button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle consult mechanic (e.g., navigate to MechanicsPage)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consult Mechanic (Not Implemented)')),
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
                child: const Text(
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
                        // Handle scan again - navigate back to camera overlay scanner
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraOverlayScanner()));
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.textColor), // Icon color
                      label: Text(
                        'Scan Again',
                        style: AppStyles.buttonText.copyWith(color: AppColors.textColor), // Text color
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.borderColor, // Using borderColor as a grey button
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
                        // TODO: Handle download functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download Report (Not Implemented)')),
                        );
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Download',
                        style: AppStyles.buttonText,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor, // Using accentColor as a distinct secondary button
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

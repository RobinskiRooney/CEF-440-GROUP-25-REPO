// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome, though not directly used in HomePage's build method, it's good practice for screens
import 'package:google_fonts/google_fonts.dart'; // For Inter font, if specific styles within HomePage use it

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
// import '../widgets/bottom_nav_bar.dart';
import '../widgets/camera_overlay_scanner.dart';
import '../pages/engine_diagnosis_page.dart';
import '../pages/profile_page.dart';
import 'help_and_support_page.dart'; // Ensure this is imported if used in bottom nav or elsewhere

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // This state is for the bottom navigation bar, if HomePage manages it directly.

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different pages here based on index
    // For now, we'll keep the HomePage as the main view and just update the selected index.
    // Navigation to specific pages like HelpAndSupportPage will be handled by explicit buttons.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Use AppColors
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildVehicleCategories(),
            _buildDiagnosisCards(context), // Pass context for navigation
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60.0, left: 24.0, right: 24.0, bottom: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightBlueGradientStart, // Lighter blue
            AppColors.blueGradientEnd, // Darker blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: AppStyles.headline1.copyWith(color: Colors.white), // Use AppStyles
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boukeng rochinel,',
                    style: AppStyles.bodyText.copyWith(color: Colors.white70), // Use AppStyles
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Handle profile picture tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage(
                      'assets/images/profile_pic.png'), // Ensure this asset exists and is declared
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading profile picture: $exception');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                suffixIcon: Icon(Icons.mic, color: Colors.white.withOpacity(0.7)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryItem(Icons.motorcycle, 'Bike'),
          _buildCategoryItem(Icons.directions_car, 'Car'),
          _buildCategoryItem(Icons.directions_bus, 'Bus'),
          _buildCategoryItem(Icons.airport_shuttle, 'Van'), // Changed label for variety
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.lightGrey, // Use AppColors
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, size: 30, color: AppColors.primaryColor), // Use AppColors
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppStyles.bodyText.copyWith(color: AppColors.textColor), // Use AppStyles
        ),
      ],
    );
  }

  Widget _buildDiagnosisCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        children: [
          _buildDiagnosisCard(
            context, // Pass context
            'Engine sound Diagnosis',
            'AI powered engine sound analysis',
            AppColors.lightBlueCard, // Use AppColors
            Icons.graphic_eq,
            () {
              // Navigate to Engine Sound Diagnosis Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EngineDiagnosisPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDiagnosisCard(
            context, // Pass context
            'Dashboard light scanning',
            'AI powered dashboard light analysis',
            AppColors.lightOrangeCard, // Use AppColors
            Icons.lightbulb_outline,
            () {
              // Navigate to Camera Overlay Scanner Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraOverlayScanner()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(
      BuildContext context, String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // Add onTap handler
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 28, color: AppColors.primaryColor), // Use AppColors
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.headline3.copyWith(color: AppColors.textColor), // Use AppStyles
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor), // Use AppStyles
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.greyTextColor, size: 20), // Use AppColors
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: AppStyles.headline2.copyWith(color: AppColors.textColor), // Use AppStyles
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildNotificationCard(
                  'assets\images\d2.jpeg', // Ensure this asset exists and is declared
                  'Last Scan', // Corrected title
                  'Parking brake is engaged, disengage it before driving.', // Corrected description
                ),
                const SizedBox(width: 15),
                _buildNotificationCard(
                  'assets/images/d1.png', // Ensure this asset exists and is declared
                  'Power Steering Problem',
                  'Imminent problems with the power steering system.',
                ),
                const SizedBox(width: 15),
                _buildNotificationCard(
                  'assets/images/d1.png', // Ensure this asset exists and is declared
                  'ABS System', // Corrected title
                  'Trouble with the Anti-lock Braking System.', // Corrected description
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String imagePath, String title, String description) {
    return Container(
      width: 160, // Fixed width for horizontal scroll
      decoration: BoxDecoration(
        color: AppColors.cardColor, // Use AppColors
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.asset(
              imagePath,
              height: 100, // Adjust height as needed
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading notification asset: $imagePath - $error');
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.broken_image, color: AppColors.greyTextColor),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.headline3.copyWith(color: AppColors.textColor), // Use AppStyles
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor), // Use AppStyles
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

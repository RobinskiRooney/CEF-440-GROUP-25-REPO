// lib/screens/profile_page.dart
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:autofix_car/pages/home_page.dart';
import 'package:autofix_car/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/profile_header.dart';
import '../constants/app_colors.dart'; // Assuming you have AppColors for consistency
import '../constants/app_styles.dart'; // Assuming you have AppStyles for consistency
import 'edit_profile_page.dart'; // Import the new edit page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Example User Profile Data
  UserProfile _userProfile = UserProfile( // Changed to non-final to allow updates
    name: 'Boukeng rochinel',
    id: '659658507',
    userLocation: 'Buea, Cameroon',
    imageUrl: 'E:\\Flutter Practice\\autofix_car\\assets\\images\\profile_pic.png', // Placeholder image
    email: 'boukengrochinel15@gmail.com',
    carModel: 'Toyota',
    mobileContact: '659 658 507',
  );

  void _onLogout() {
    // Implement your logout logic here
    print('User logged out!');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
        Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void _onEditProfile() async { // Made async to await result from EditProfilePage
    print('Edit Profile option selected!');
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userProfile: _userProfile),
      ),
    );

    // If an updated profile is returned from EditProfilePage, update the state
    if (updatedProfile != null && updatedProfile is UserProfile) {
      setState(() {
        _userProfile = updatedProfile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _onForgotPassword() {
    // Implement navigation to Forgot Password screen or dialog
    print('Forgot Password option selected!');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Forgot Password...')),
    );
       Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Using AppColors for consistency
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(userProfile: _userProfile),
            PersonalInfoCard(
              userProfile: _userProfile,
              onLogout: _onLogout,
            ),
            const SizedBox(height: 20), // Spacing after personal info card

            // New Section for Account Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: AppStyles.headline4.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit_outlined, color: AppColors.primaryColor),
                          title: Text(
                            'Edit Profile',
                            style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.greyTextColor),
                          onTap: _onEditProfile,
                        ),
                        Divider(indent: 16, endIndent: 16, height: 1, color: AppColors.lightGrey),
                        ListTile(
                          leading: Icon(Icons.lock_reset_outlined, color: AppColors.primaryColor),
                          title: Text(
                            'Change Password', // Changed to "Change Password" as it's more common
                            style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.greyTextColor),
                          onTap: _onForgotPassword, // Using the same function for simplicity
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add some spacing at the bottom
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () {
          // No need to pop, as the MainNavigation handles switching
          // You might navigate to a login screen or a specific main tab
          print('Back button pressed on Profile Page');
          // If this page is part of a navigation stack, you'd usually do Navigator.pop(context);
          // For a main tab, you might do nothing or navigate to home.
        Navigator.pop(context); // Navigate ba
        },
      ),
      title: const Text(
        'Profile',
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications button pressed!')),
            );
          },
        ),
      ],
    );
  }
}
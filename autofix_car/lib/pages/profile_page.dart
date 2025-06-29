// lib/screens/profile_page.dart
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:autofix_car/pages/home_page.dart';
// import 'package:autofix_car/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../widgets/personal_info_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/profile_header.dart';
import '../constants/app_colors.dart'; // Assuming you have AppColors for consistency
import '../constants/app_styles.dart'; // Assuming you have AppStyles for consistency
import 'edit_profile_page.dart'; // Import the new edit page
import 'login_page.dart';
// import '../services/auth_service.dart';
import '../services/token_manager.dart';
import './admin_add_mechanic_page.dart';
import './admin_dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String _authMessage = ''; // Message to display to the user
String? _displayEmail; // For displaying logged-in user info (optional)
String? _displayUid; // For displaying logged-in user info (optional)

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndRole();
  }

  Future<void> _fetchUserProfileAndRole() async {
    setState(() { _isLoading = true; });
    try {
      // Fetch user profile from backend
      final token = await TokenManager.getIdToken();
      final userId = await TokenManager.getUid();
      final response = await http.get(
        Uri.parse('http://localhost:5000/users/:$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userProfile = UserProfile.fromJson(data);
        setState(() {
          _userProfile = userProfile;
          _isAdmin = userProfile.role == 'admin';
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  // Handles the logout process
  Future<void> _handleLogout() async {
    await TokenManager.clearTokens(); // Clear tokens from secure storage
    setState(() {
      _displayEmail = null;
      _displayUid = null;
      _authMessage = 'Logged out successfully.';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out.')));
    // Navigate back to the login page (or root, depending on your app flow)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _redirectCreateMechanics() async {
    // Navigate to the Create Mechanic page
    print('Redirecting to Create Mechanic page...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminAddMechanicPage()),
    );
  }

  Future<void> _redirectAdmin() async {
    // Navigate to the Create Mechanic page
    print('Redirecting to Create Mechanic page...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
    );
  }

  // void _handleLogout() {
  //   // Implement your logout logic here
  //   print('User logged out!');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Logged out successfully!')),
  //   );
  //       Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const WelcomePage()),
  //   );
  // }

  void _onEditProfile() async {
    // Made async to await result from EditProfilePage
    print('Edit Profile option selected!');
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userProfile: _userProfile!),
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
      backgroundColor:
          AppColors.backgroundColor, // Using AppColors for consistency
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading)
            const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
            )
            else if (_userProfile != null) ...[
            ProfileHeader(userProfile: _userProfile!),
            PersonalInfoCard(
            userProfile: _userProfile!,
            onLogout: _handleLogout,
            ),
            ],
            const SizedBox(height: 20), // Spacing after personal info card
            // New Section for Account Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: AppStyles.headline4.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                  children: [
                  ListTile(
                  leading: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryColor,
                  ),
                  title: Text(
                  'Edit Profile',
                  style: AppStyles.bodyText.copyWith(
                  color: AppColors.textColor,
                  ),
                  ),
                  trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.greyTextColor,
                  ),
                  onTap: _onEditProfile,
                  ),
                  Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  color: AppColors.lightGrey,
                  ),
                  ListTile(
                  leading: Icon(
                  Icons.lock_reset_outlined,
                  color: AppColors.primaryColor,
                  ),
                  title: Text(
                  'Change Password',
                  style: AppStyles.bodyText.copyWith(
                  color: AppColors.textColor,
                  ),
                  ),
                  trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.greyTextColor,
                  ),
                  onTap: _onForgotPassword,
                  ),
                  if (_isAdmin) ...[
                  Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  color: AppColors.lightGrey,
                  ),
                  ListTile(
                  leading: Icon(
                  Icons.engineering,
                  color: AppColors.primaryColor,
                  ),
                  title: Text(
                  'Create Mechanic',
                  style: AppStyles.bodyText.copyWith(
                  color: AppColors.textColor,
                  ),
                  ),
                  trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.greyTextColor,
                  ),
                  onTap: _redirectCreateMechanics,
                  ),
                  ListTile(
                  leading: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primaryColor,
                  ),
                  title: Text(
                  'Admin Dashboard',
                  style: AppStyles.bodyText.copyWith(
                  color: AppColors.textColor,
                  ),
                  ),
                  trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.greyTextColor,
                  ),
                  onTap: _redirectAdmin,
                  ),
                  ],
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

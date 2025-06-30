// lib/screens/edit_profile_page.dart
import 'dart:io'; // For File

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:flutter/foundation.dart'; // For debugPrint

import '../models/user_profile.dart'; // Import the UserProfile model
import '../constants/app_colors.dart'; // Ensure correct import path for AppColors
import '../constants/app_styles.dart'; // Ensure correct import path for AppStyles


class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _carModelController;
  late TextEditingController _mobileContactController;

  File? _pickedImageFile; // Stores the local image file selected by the user
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user profile data
    _nameController = TextEditingController(text: widget.userProfile.name);
    _idController = TextEditingController(text: widget.userProfile.id);
    _locationController = TextEditingController(text: widget.userProfile.userLocation);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _carModelController = TextEditingController(text: widget.userProfile.carModel);
    _mobileContactController = TextEditingController(text: widget.userProfile.mobileContact);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _idController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _carModelController.dispose();
    _mobileContactController.dispose();
    super.dispose();
  }

  // Method to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 75); // Compress image
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path); // Convert XFile to File
        });
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e'); // Use debugPrint for logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Shows a bottom sheet to let the user choose image source
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    // IMPORTANT: In this version, the image picked from local files
    // is NOT being uploaded to a server or saved persistently.
    // It is only displayed temporarily during the app session.
    // If you need persistence, you must integrate cloud storage (e.g., Firebase Storage).

    final updatedUserProfile = UserProfile(
      uid: widget.userProfile.uid, // uid must be passed
      name: _nameController.text,
      id: _idController.text,
      userLocation: _locationController.text,
      // For now, imageUrl remains the original. If you want to pass the local path,
      // UserProfile would need to support a local file path field.
      imageUrl: widget.userProfile.imageUrl, // Or use _pickedImageFile.path if you want to store local path temporarily
      email: _emailController.text,
      carModel: _carModelController.text,
      mobileContact: _mobileContactController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully! (Local display only)')),
    );

    // Pass the updated text fields back. The profile image displayed on the previous
    // screen will revert to its original if not loaded from a persistent source.
    Navigator.pop(context, updatedUserProfile);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the image provider based on the available image source
    ImageProvider<Object>? backgroundImageProvider;
    if (_pickedImageFile != null) {
      backgroundImageProvider = FileImage(_pickedImageFile!);
    } else if (widget.userProfile.imageUrl != null && widget.userProfile.imageUrl!.isNotEmpty) {
      backgroundImageProvider = NetworkImage(widget.userProfile.imageUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.borderColor, // Changed to borderColor for consistency
                    backgroundImage: backgroundImageProvider, // Use the determined image provider
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Error loading image: $exception'); // Use debugPrint
                    },
                    // Show default icon if no image picked and no network image
                    child: backgroundImageProvider == null
                        ? Icon(Icons.person, size: 60, color: AppColors.secondaryTextColor) // Used secondaryTextColor
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context), // Show image source options
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.backgroundColor, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _idController,
              labelText: 'User ID',
              hintText: 'Your unique ID',
              icon: Icons.badge_outlined,
              readOnly: true, // User ID is typically not editable
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _mobileContactController,
              labelText: 'Mobile Contact',
              hintText: 'Enter your mobile number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              labelText: 'Location',
              hintText: 'Your current location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _carModelController,
              labelText: 'Car Model',
              hintText: 'Your car model',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50), // Make button full width
                ),
                child: const Text(
                  'Save Changes',
                  style: AppStyles.buttonText, // Already correctly using AppStyles.buttonText
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      // Corrected: Use bodyText1 as bodyText is not defined in AppStyles
      style: AppStyles.bodyText1.copyWith(color: AppColors.textColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Corrected: Use secondaryTextColor instead of greyTextColor
        labelStyle: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor),
        hintStyle: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Corrected: Use borderColor instead of lightGrey
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Navigator.pop(context); // Go back to the previous page (ProfilePage)
        },
      ),
      title: Text(
        'Edit Profile',
        // Corrected: Use headline3 as headline4 is not defined in AppStyles
        style: AppStyles.headline3.copyWith(color: AppColors.textColor),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.save_outlined, color: AppColors.primaryColor),
          onPressed: _saveProfile,
          tooltip: 'Save Changes',
        ),
      ],
    );
  }
}

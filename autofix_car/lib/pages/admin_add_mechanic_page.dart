// lib/pages/admin_add_mechanic_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:flutter/foundation.dart'; // For debugPrint

import '../models/mechanic.dart'; // Import the Mechanic model
import '../services/mechanic_service.dart'; // Import the MechanicService
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles
import '../widgets/custom_text_field.dart'; // Re-using your CustomTextField for consistency

class AdminAddMechanicPage extends StatefulWidget {
  const AdminAddMechanicPage({super.key});

  @override
  State<AdminAddMechanicPage> createState() => _AdminAddMechanicPageState();
}

class _AdminAddMechanicPageState extends State<AdminAddMechanicPage> {
  // Page controller for managing sections
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Text editing controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _specialtiesController = TextEditingController();

  // Dropdown value for verification status
  String _selectedVerificationStatus = 'Unverified'; // Default value

  // State for loading indicator during save
  bool _isSaving = false;

  // Form keys for validation
  final GlobalKey<FormState> _basicInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _pageController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _ratingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  // Method to validate current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicInfoFormKey.currentState?.validate() ?? false;
      case 1:
        return _contactFormKey.currentState?.validate() ?? false;
      case 2:
        return _locationFormKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  // Method to go to next step
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _saveMechanic();
      }
    }
  }

  // Method to go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to handle saving the new mechanic
  Future<void> _saveMechanic() async {
    setState(() {
      _isSaving = true; // Set loading state
    });

    // Parse numerical inputs
    final double? rating = double.tryParse(_ratingController.text);
    final double? latitude = double.tryParse(_latitudeController.text);
    final double? longitude = double.tryParse(_longitudeController.text);

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude and Longitude must be valid numbers.')),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    // Prepare specialties list from comma-separated string
    final List<String> specialties = _specialtiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      // Create a Mechanic object
      final newMechanic = Mechanic(
        id: '', // ID is assigned by the backend
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        rating: rating ?? 0.0, // Default to 0.0 if parsing fails
        verificationStatus: _selectedVerificationStatus,
        latitude: latitude,
        longitude: longitude,
        specialties: specialties,
      );

      // Call the service to create the mechanic in the backend
      await MechanicService.createMechanic(newMechanic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mechanic added successfully!')),
        );
        // Optionally, clear form or navigate back
        Navigator.pop(context); // Go back to previous page (e.g., MechanicsPage)
      }
    } catch (e) {
      debugPrint('Error creating mechanic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add mechanic: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoSection(),
                _buildContactSection(),
                _buildLocationSection(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // Progress indicator widget
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? AppColors.primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Section 1: Basic Information
  Widget _buildBasicInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: AppStyles.headline2.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Step 1 of 3',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 24),

            // Name
            CustomTextField(
              controller: _nameController,
              hintText: 'Mechanic Name',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.text,
              validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            // Address
            CustomTextField(
              controller: _addressController,
              hintText: 'Address',
              prefixIcon: Icons.location_on_outlined,
              keyboardType: TextInputType.streetAddress,
              validator: (value) => value!.isEmpty ? 'Address cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            // Rating
            CustomTextField(
              controller: _ratingController,
              hintText: 'Rating (0.0 - 5.0)',
              prefixIcon: Icons.star_outline,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return null; // Optional field
                final double? num = double.tryParse(value);
                if (num == null || num < 0 || num > 5) {
                  return 'Enter a rating between 0.0 and 5.0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Specialties
            CustomTextField(
              controller: _specialtiesController,
              hintText: 'Specialties (comma-separated, e.g., Engine, Brakes)',
              prefixIcon: Icons.build_circle_outlined,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),

            // Verification Status Dropdown
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Verification Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.verified_outlined, color: AppColors.secondaryTextColor),
                filled: true,
                fillColor: AppColors.inputFillColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVerificationStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryTextColor),
                  items: <String>['Verified', 'Unverified']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppStyles.bodyText1),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVerificationStatus = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 2: Contact Information
  Widget _buildContactSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: AppStyles.headline2.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Step 2 of 3',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 24),

            // Phone
            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number (e.g., +237677123456)',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Phone number cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            // Email (Optional)
            CustomTextField(
              controller: _emailController,
              hintText: 'Email (Optional)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // Optional field
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Website (Optional)
            CustomTextField(
              controller: _websiteController,
              hintText: 'Website (Optional)',
              prefixIcon: Icons.public,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // Optional field
                if (!RegExp(r'^https?://').hasMatch(value)) {
                  return 'Website should start with http:// or https://';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Section 3: Location Information
  Widget _buildLocationSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Information',
              style: AppStyles.headline2.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Step 3 of 3',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 24),

            // Latitude
            CustomTextField(
              controller: _latitudeController,
              hintText: 'Latitude',
              prefixIcon: Icons.map_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Latitude cannot be empty';
                }
                final double? lat = double.tryParse(value);
                if (lat == null || lat < -90 || lat > 90) {
                  return 'Enter a valid latitude (-90 to 90)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Longitude
            CustomTextField(
              controller: _longitudeController,
              hintText: 'Longitude',
              prefixIcon: Icons.map_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Longitude cannot be empty';
                }
                final double? lng = double.tryParse(value);
                if (lng == null || lng < -180 || lng > 180) {
                  return 'Enter a valid longitude (-180 to 180)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Summary card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Information',
                      style: AppStyles.headline3.copyWith(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Name', _nameController.text),
                    _buildSummaryRow('Phone', _phoneController.text),
                    _buildSummaryRow('Address', _addressController.text),
                    if (_emailController.text.isNotEmpty)
                      _buildSummaryRow('Email', _emailController.text),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Summary row widget
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppStyles.bodyText2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: AppStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation buttons
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Previous/Back button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primaryColor),
                ),
                child: const Text('Previous'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          // Next/Save button
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_currentStep < 2 ? 'Next' : 'Add Mechanic'),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar builder method
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () {
          Navigator.pop(context); // Go back to the previous page
        },
      ),
      title: Text(
        'Add Mechanic',
        style: AppStyles.headline3.copyWith(color: AppColors.textColor),
      ),
      centerTitle: true,
    );
  }
}
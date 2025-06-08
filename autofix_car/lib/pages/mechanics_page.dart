// lib/screens/mechanics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import '../models/mechanic.dart';
import '../models/map_location.dart';
import '../widgets/map_section.dart';
import '../widgets/mechanic_card.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  _MechanicsPageState createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  final TextEditingController _searchController = TextEditingController();

  // List of Cameroon regions
  final List<String> _cameroonRegions = [
    'Adamawa',
    'Centre',
    'East',
    'Far North',
    'Littoral',
    'North',
    'Northwest',
    'South',
    'Southwest',
    'West',
  ];

  // Currently selected region, initialized to 'Southwest' as Buea is in Southwest
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedRegion = _cameroonRegions[8]; // Initialize with 'Southwest'
  }

  // UPDATED: Added placeholder phone numbers for locations where applicable
  final List<MapLocation> _mapLocations = [
    MapLocation(
      name: "BUEA FILM ACADEMY",
      type: LocationType.academy,
      position: const Offset(280, 115),
      phoneNumber: "+237677123456", // Example number
    ),
    MapLocation(
      name: "Pinorich Villa",
      type: LocationType.hotel,
      position: const Offset(330, 168),
      phoneNumber: "+237699765432", // Example number
    ),
    MapLocation(
      name: "Longho Lodge Bonduma - Buea",
      type: LocationType.hotel,
      position: const Offset(210, 268),
      phoneNumber: "+237677234567", // Example number
    ),
    MapLocation(
      name: "Buea Town Stadium",
      type: LocationType.stadium,
      position: const Offset(80, 235),
      // No phone number for a stadium usually
    ),
    MapLocation(
      name: "Central Administration University of Buea",
      type: LocationType.university,
      position: const Offset(200, 340),
      phoneNumber: "+237243123456", // Example number
    ),
  ];

  // UPDATED: Added placeholder phone numbers for mechanics
  final List<Mechanic> _mechanics = [
    Mechanic(
      name: "Nash Car Fix",
      address: "B 1234 EA",
      location: "Buea, Cameroon",
      imageUrl: "https://via.placeholder.com/50x50/4CAF50/FFFFFF?text=NC",
      rating: 4.8,
      isVerified: true,
      phoneNumber: "+237678112233", // Example Nash Car Fix
    ),
    Mechanic(
      name: "Auto Repair Hub",
      address: "Molyko, Great Soppo",
      location: "Buea, Cameroon",
      imageUrl: "https://via.placeholder.com/50x50/2196F3/FFFFFF?text=AH",
      rating: 4.5,
      isVerified: false,
      phoneNumber: "+237659658507", // Example Auto Repair Hub
    ),
    Mechanic(
      name: "Speedy Motors",
      address: "Check Point, Bomaka",
      location: "Buea, Cameroon",
      imageUrl: "assets/images/profile_pic.png",
      rating: 4.9,
      isVerified: true,
      phoneNumber: "+237677998877", // Example Speedy Motors
    ),
  ];

  // --- NEW: Utility functions for launching calls and WhatsApp ---

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone dialer for $phoneNumber')),
      );
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    // For WhatsApp, using wa.me is generally more reliable cross-platform
    // phoneNumber should be in international format without '+' or '00' (e.g., 237677123456)
    final String url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    final Uri launchUri = Uri.parse(url);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp for $phoneNumber. Make sure WhatsApp is installed.')),
      );
    }
  }

  // --- END NEW UTILITY FUNCTIONS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          MapSection(
            mapLocations: _mapLocations,
            onLocationTap: _showLocationDetails,
          ),
          _buildSearchSection(),
          Expanded(child: _buildMechanicsList()),
          _buildPersonalInfo(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Mechanics',
        style: AppStyles.headline4.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Handle notification button press
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a mechanic',
          hintStyle: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.greyTextColor,
          ),
          suffixIcon: Icon(
            Icons.mic,
            color: AppColors.greyTextColor,
          ),
          filled: true,
          fillColor: AppColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (query) {
          // Implement search logic here
        },
      ),
    );
  }

  Widget _buildMechanicsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mechanic Information',
            style: AppStyles.headline4.copyWith(color: AppColors.textColor),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mechanics.length,
            itemBuilder: (context, index) {
              final mechanic = _mechanics[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: MechanicCard(
                  mechanic: mechanic,
                  onMessage: (mechanic) {
                    // Call WhatsApp function
                    _launchWhatsApp(mechanic.phoneNumber.replaceAll('+', ''), 'Hello ${mechanic.name}, I need assistance with my car from the AutoFix app.'); // Remove '+' for wa.me
                  },
                  onCall: (mechanic) {
                    // Call phone call function
                    _makePhoneCall(mechanic.phoneNumber);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: AppStyles.smallText.copyWith(color: AppColors.greyTextColor),
              ),
              DropdownButton<String>(
                value: _selectedRegion,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColor),
                iconSize: 24,
                elevation: 16,
                style: AppStyles.bodyText.copyWith(color: AppColors.textColor, fontWeight: FontWeight.w500),
                underline: Container(
                  height: 0,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                    print('Selected region: $_selectedRegion');
                  });
                },
                items: _cameroonRegions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(MapLocation location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: AppStyles.headline4.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${location.type.toString().split('.').last}',
              style: AppStyles.smallText.copyWith(color: AppColors.greyTextColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulate getting directions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Getting directions to ${location.name}')),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Get Directions',
                      style: AppStyles.buttonText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: location.phoneNumber != null
                        ? () {
                            _makePhoneCall(location.phoneNumber!);
                            Navigator.pop(context);
                          }
                        : null, // Disable if no phone number
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Call',
                      style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: location.phoneNumber != null
                        ? () {
                            // Using location.name as part of the message for context
                            _launchWhatsApp(location.phoneNumber!.replaceAll('+', ''), 'Hello ${location.name}, I need assistance from the AutoFix app.');
                            Navigator.pop(context);
                          }
                        : null, // Disable if no phone number
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Message',
                      style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
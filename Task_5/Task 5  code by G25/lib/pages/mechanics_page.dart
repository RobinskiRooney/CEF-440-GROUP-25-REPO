// lib/screens/mechanics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mechanic.dart';
import '../models/map_location.dart';
import '../widgets/map_section.dart';
import '../widgets/mechanic_card.dart';
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles

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

  final List<MapLocation> _mapLocations = [
    MapLocation(
      name: "BUEA FILM ACADEMY",
      type: LocationType.academy,
      position: const Offset(280, 115),
    ),
    MapLocation(
      name: "Pinorich Villa",
      type: LocationType.hotel,
      position: const Offset(330, 168),
    ),
    MapLocation(
      name: "Longho Lodge Bonduma - Buea",
      type: LocationType.hotel,
      position: const Offset(210, 268),
    ),
    MapLocation(
      name: "Buea Town Stadium",
      type: LocationType.stadium,
      position: const Offset(80, 235),
    ),
    MapLocation(
      name: "Central Administration University of Buea",
      type: LocationType.university,
      position: const Offset(200, 340),
    ),
  ];

  final List<Mechanic> _mechanics = [
    Mechanic(
      name: "Nash Car Fix",
      address: "B 1234 EA",
      location: "Buea, Cameroon",
      imageUrl: "https://via.placeholder.com/50x50/4CAF50/FFFFFF?text=NC",
      rating: 4.8,
      isVerified: true,
    ),
    Mechanic(
      name: "Auto Repair Hub",
      address: "Molyko, Great Soppo",
      location: "Buea, Cameroon",
      imageUrl: "https://via.placeholder.com/50x50/2196F3/FFFFFF?text=AH",
      rating: 4.5,
      isVerified: false,
    ),
    Mechanic(
      name: "Speedy Motors",
      address: "Check Point, Bomaka",
      location: "Buea, Cameroon",
      imageUrl: "https://via.placeholder.com/50x50/FF9800/FFFFFF?text=SM",
      rating: 4.9,
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Using AppColors
      appBar: _buildAppBar(context), // Pass context to AppBar method
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

  PreferredSizeWidget _buildAppBar(BuildContext context) { // Accept context
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Using AppColors
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.pop(context); // Handle back button press
        },
      ),
      title: Text(
        'Mechanics',
        style: AppStyles.headline4.copyWith(color: Colors.white), // Using AppStyles
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
          hintStyle: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor), // Using AppStyles and AppColors
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.greyTextColor, // Using AppColors
          ),
          suffixIcon: Icon(
            Icons.mic,
            color: AppColors.greyTextColor, // Using AppColors
          ),
          filled: true,
          fillColor: AppColors.lightGrey, // Using AppColors
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
            style: AppStyles.headline4.copyWith(color: AppColors.textColor), // Using AppStyles and AppColors
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mechanics.length,
            itemBuilder: (context, index) {
              return Padding( // Added Padding for better spacing between cards
                padding: const EdgeInsets.only(bottom: 8.0),
                child: MechanicCard(
                  mechanic: _mechanics[index],
                  onMessage: (mechanic) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message ${mechanic.name}')),
                    );
                  },
                  onCall: (mechanic) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Call ${mechanic.name}')),
                    );
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
        color: AppColors.lightGrey, // Using AppColors
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentColor, // Using AppColors (AccentColor is a yellow/amber)
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
                style: AppStyles.smallText.copyWith(color: AppColors.greyTextColor), // Using AppStyles and AppColors
              ),
              // const SizedBox(height: 2),
              // MODIFIED: Replaced static 'Buea' text with a DropdownButton
              DropdownButton<String>(
                value: _selectedRegion,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColor),
                iconSize: 24,
                elevation: 16,
                style: AppStyles.bodyText.copyWith(color: AppColors.textColor, fontWeight: FontWeight.w500),
                underline: Container(
                  height: 0, // No underline
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                    // You might want to filter mechanics or update map based on new region here
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
              style: AppStyles.headline4.copyWith(color: AppColors.textColor), // Using AppStyles and AppColors
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${location.type.toString().split('.').last}',
              style: AppStyles.smallText.copyWith(color: AppColors.greyTextColor), // Using AppStyles and AppColors
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
                      backgroundColor: AppColors.primaryColor, // Using AppColors
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Get Directions',
                      style: AppStyles.buttonText, // Using AppStyles
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Simulate calling
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${location.name}')),
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor, width: 2), // Using AppColors
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Call',
                      style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor), // Using AppStyles and AppColors
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Added spacing
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Simulate messaging
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Messaging ${location.name}')),
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor, width: 2), // Using AppColors
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Message',
                      style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor), // Using AppStyles and AppColors
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

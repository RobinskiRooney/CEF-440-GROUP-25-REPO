// lib/pages/mechanics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:url_launcher/url_launcher.dart'; // For making calls/opening websites

import '../models/mechanic.dart'; // Import the Mechanic model
import '../services/mechanic_service.dart'; // Import the MechanicService
import '../constants/app_colors.dart'; // General app colors
import '../constants/app_styles.dart'; // General app text styles
import '../widgets/mechanic_card.dart'; // Import MechanicCard widget


class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  State<MechanicsPage> createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Mechanic> _mechanics = []; // Original list of all fetched mechanics
  List<Mechanic> _filteredMechanics = []; // List to hold mechanics after applying filters
  bool _isLoading = true; // State for loading data
  String _errorMessage = ''; // State for displaying error messages

  // List of Cameroon regions
  final List<String> _cameroonRegions = [
    'All Regions', // Added an option to view all regions
    'Adamawa', 'Centre', 'East', 'Far North', 'Littoral',
    'North', 'North-West', 'South', 'South-West', 'West'
  ];

  // Currently selected region, initialized to 'South-West'
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedRegion = _cameroonRegions[0]; // Initialize with 'South-West'
    _loadMechanics(); // Load mechanics when the page initializes
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Data Loading Functions ---

  Future<void> _loadMechanics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous error messages
    });
    try {
      _mechanics = await MechanicService.getAllMechanics();
      _applyFilters(); // Apply filters immediately after loading to populate _filteredMechanics
    } catch (e) {
      debugPrint('Error loading mechanics: $e');
      setState(() {
        _errorMessage = 'Failed to load mechanics: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Always set loading to false in finally block
      });
    }
  }

  // --- Search and Filter Logic ---
  void _applyFilters() {
    final String query = _searchController.text.toLowerCase();
    final String? region = _selectedRegion;

    setState(() {
      _filteredMechanics = _mechanics.where((mechanic) {
        final bool matchesSearch = mechanic.name.toLowerCase().contains(query) ||
                                  mechanic.address.toLowerCase().contains(query) ||
                                  mechanic.specialties.any((s) => s.toLowerCase().contains(query));

        // Note: Your Mechanic model does not have a 'location' field,
        // but often the 'address' field contains location info.
        // If you want to filter by region, your Mechanic model needs a 'region' field
        // or a way to derive it from the 'address' or coordinates.
        // For now, I'm adding a placeholder for region filtering.
        final bool matchesRegion = region == null || region == 'All Regions' ||
                                   (mechanic.address.toLowerCase().contains(region.toLowerCase()));
                                   // This is a naive check; a real app might use geocoding or a dedicated 'region' field

        return matchesSearch && matchesRegion;
      }).toList();
    });
  }

  // --- Utility functions for launching external apps ---

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedPhoneNumber,
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
    final cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final String url = 'https://wa.me/$cleanedPhoneNumber?text=${Uri.encodeComponent(message)}';
    final Uri launchUri = Uri.parse(url);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp for $phoneNumber. Make sure WhatsApp is installed.')),
      );
    }
  }

  Future<void> _openWebsite(String? websiteUrl) async {
    if (websiteUrl == null || websiteUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No website available for this mechanic.')),
      );
      return;
    }
    final Uri launchUri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $websiteUrl')),
      );
    }
  }

  // --- UI Building Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: AppStyles.errorText, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMechanics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search and Filter Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for a mechanic (name, address, specialty)',
                              hintStyle: AppStyles.bodyText2,
                              prefixIcon: const Icon(Icons.search, color: AppColors.secondaryTextColor),
                              suffixIcon: const Icon(Icons.mic, color: AppColors.secondaryTextColor),
                              filled: true,
                              fillColor: AppColors.inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (query) {
                              _applyFilters(); // Apply filters on search query change
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedRegion,
                            hint: const Text('Filter by Region'),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.location_on),
                              filled: true,
                              fillColor: AppColors.inputFillColor,
                            ),
                            items: _cameroonRegions.map((String region) {
                              return DropdownMenuItem<String>(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRegion = newValue;
                                _applyFilters(); // Apply filters on region change
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mechanic Information List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nearby Mechanics (${_filteredMechanics.length})', // Show count
                          style: AppStyles.headline3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mechanics List
                    Expanded(
                      child: _filteredMechanics.isEmpty
                          ? Center(
                              child: Text(
                                _mechanics.isEmpty
                                    ? 'No mechanics available.'
                                    : 'No mechanics found matching your criteria.',
                                style: AppStyles.bodyText2,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : RefreshIndicator( // Added RefreshIndicator
                              onRefresh: _loadMechanics,
                              color: AppColors.primaryColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _filteredMechanics.length,
                                itemBuilder: (context, index) {
                                  final mechanic = _filteredMechanics[index];
                                  return MechanicCard(
                                    mechanic: mechanic,
                                    onMessage: (mech) => _launchWhatsApp(mech.phone, 'Hello ${mech.name}, I need assistance with my car from the AutoFix app.'),
                                    onCall: (mech) => _makePhoneCall(mech.phone),
                                    onShare: (mech) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Share details for ${mech.name} (not implemented)')),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
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
        style: AppStyles.headline3.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications (Not Implemented)')),
            );
          },
        ),
      ],
    );
  }

  void _showMechanicDetailsModal(Mechanic mechanic) {
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
              mechanic.name,
              style: AppStyles.headline3.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              mechanic.address,
              style: AppStyles.bodyText2,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                Text('${mechanic.rating.toStringAsFixed(1)}', style: AppStyles.bodyText2),
                const SizedBox(width: 8),
                Icon(
                  mechanic.verificationStatus == 'Verified' ? Icons.verified : Icons.error_outline,
                  color: mechanic.verificationStatus == 'Verified' ? AppColors.successColor : AppColors.warningColor,
                  size: 18,
                ),
                Text(mechanic.verificationStatus, style: AppStyles.bodyText2),
              ],
            ),
            const SizedBox(height: 16),
            if (mechanic.email != null && mechanic.email!.isNotEmpty)
              _buildDetailRow(Icons.email, 'Email', mechanic.email!),
            if (mechanic.phone.isNotEmpty)
              _buildDetailRow(Icons.phone, 'Phone', mechanic.phone),
            if (mechanic.website != null && mechanic.website!.isNotEmpty)
              _buildDetailRow(Icons.public, 'Website', mechanic.website!),
            if (mechanic.specialties.isNotEmpty)
              _buildDetailRow(Icons.build, 'Specialties', mechanic.specialties.join(', ')),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _makePhoneCall(mechanic.phone);
                      Navigator.pop(context); // Close modal after action
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _launchWhatsApp(mechanic.phone, 'Hello ${mechanic.name}, I need assistance from the AutoFix app.');
                      Navigator.pop(context); // Close modal after action
                    },
                    icon: Icon(Icons.chat), // Use a chat icon as a placeholder for WhatsApp
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Removed "View on Map" button
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryTextColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.labelText.copyWith(fontWeight: FontWeight.w600)),
              Text(value, style: AppStyles.bodyText1),
            ],
          ),
        ],
      ),
    );
  }
}

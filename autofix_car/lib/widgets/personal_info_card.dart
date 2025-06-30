import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/info_row.dart';

class PersonalInfoCard extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onLogout;

  const PersonalInfoCard({
    super.key,
    required this.userProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    String notProvided = 'Not provided';

    // Handle location as a map with display_name, lat, lon
    String locationDisplay = notProvided;
    if (userProfile.userLocation != null && userProfile.userLocation is Map) {
      final loc = userProfile.userLocation as Map;
      locationDisplay = loc['display_name'] ?? notProvided;
    } else if (userProfile.userLocation is String &&
        (userProfile.userLocation as String).isNotEmpty) {
      locationDisplay = userProfile.userLocation as String;
    }

    // Format updatedAt
    String updatedAtStr = notProvided;
    if (userProfile.updatedAt != null) {
      updatedAtStr = '${userProfile.updatedAt}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24, thickness: 0.5, color: Colors.grey),
          InfoRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: (userProfile.name ?? '').isNotEmpty
                ? userProfile.name!
                : notProvided,
          ),
          InfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Car model',
            value: (userProfile.carModel ?? '').isNotEmpty
                ? userProfile.carModel!
                : notProvided,
          ),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: (userProfile.mobileContact ?? '').isNotEmpty
                ? userProfile.mobileContact!
                : notProvided,
          ),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: locationDisplay,
          ),
          InfoRow(
            icon: Icons.update,
            label: 'Last Updated',
            value: updatedAtStr,
          ),
          InfoRow(
            icon: Icons.logout,
            label: 'Logout',
            value: 'Logout',
            valueColor: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/info_row.dart';

class PersonalInfoCard extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onLogout; // Callback for logout

  const PersonalInfoCard({
    super.key,
    required this.userProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
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
            icon: Icons.email_outlined,
            label: 'Email',
            value: userProfile.email,
          ),
          InfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Car model',
            value: userProfile.carModel ?? '',
          ),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: userProfile.userLocation ?? '',
          ),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile contact',
            value: userProfile.mobileContact ?? '',
          ),
          InfoRow(
            icon: Icons.logout,
            label: 'Mobile contact', // The label on the UI is "Mobile contact" for Logout, but it's probably just "Logout"
            value: 'Logout',
            valueColor: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
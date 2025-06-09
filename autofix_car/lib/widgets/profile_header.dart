import 'package:flutter/material.dart';
import '../models/user_profile.dart'; // Assuming models folder exists

class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileHeader({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(userProfile.imageUrl ?? ''),
            backgroundColor: Colors.blue.shade100,
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback to a placeholder icon or color if image fails to load
              // You might want to log this error in a real app
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile.uid,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  userProfile.userLocation ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          // Column(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         color: Colors.blue.shade600,
          //         shape: BoxShape.circle,
          //       ),
          //       child: const Icon(
          //         Icons.message_outlined,
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //     ),
          //     const SizedBox(height: 8),
          //     Container(
          //       padding: const EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         color: Colors.blue.shade600,
          //         shape: BoxShape.circle,
          //       ),
          //       child: const Icon(
          //         Icons.phone,
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
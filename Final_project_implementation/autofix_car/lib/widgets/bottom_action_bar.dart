import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onThumbnailTap;
  final VoidCallback onCameraTap;
  final VoidCallback onCheckTap;
  final String? thumbnailImageUrl; // Optional: to display a preview

  const BottomActionBar({
    super.key,
    required this.onThumbnailTap,
    required this.onCameraTap,
    required this.onCheckTap,
    this.thumbnailImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Thumbnail button
          GestureDetector(
            onTap: onThumbnailTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.grey.shade800, // Placeholder background
                image: thumbnailImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(thumbnailImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: thumbnailImageUrl == null
                  ? const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24)
                  : null, // Display icon if no image
            ),
          ),
          // Camera button (large)
          GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF3182CE), // Blue background
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3182CE).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          // Checkmark button
          GestureDetector(
            onTap: onCheckTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade600, // Green background
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
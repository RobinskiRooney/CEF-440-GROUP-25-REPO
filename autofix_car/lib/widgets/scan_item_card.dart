// lib/widgets/scan_item_card.dart
import 'package:flutter/material.dart';
import '../models/scan_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class ScanItemCard extends StatelessWidget {
  final ScanData scan;

  const ScanItemCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Rounded corners for the image
              child: Image.network(
                scan.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: AppColors.lightGrey,
                    child: const Icon(Icons.image_not_supported, color: AppColors.greyTextColor),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.title,
                    style: AppStyles.headline3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.description,
                    style: AppStyles.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Optional: Add an arrow or indicator if it's tappable
            const Icon(Icons.arrow_forward_ios, color: AppColors.greyTextColor, size: 16),
          ],
        ),
      ),
    );
  }
}
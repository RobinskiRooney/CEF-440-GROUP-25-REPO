// lib/widgets/scan_item_card.dart
import 'package:flutter/material.dart';
import 'package:autofix_car/models/scan_data.dart'; // Import ScanData model
import 'package:autofix_car/constants/app_colors.dart'; // Import AppColors
import 'package:autofix_car/constants/app_styles.dart'; // Import AppStyles

class ScanItemCard extends StatelessWidget {
  final ScanData scan;
  final VoidCallback? onTap; // Optional callback for tapping the card

  const ScanItemCard({
    super.key,
    required this.scan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          // Default action: show a snackbar or navigate to scan details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing scan details for: ${scan.title}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image/Icon for the scan item
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.inputFillColor, // Light background for image area
                  image: DecorationImage(
                    image: NetworkImage(scan.imagePath), // Use NetworkImage for URL
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback for image loading errors
                      debugPrint('Error loading scan image: $exception');
                      // Can display a placeholder icon/text instead
                    },
                  ),
                ),
                // Optional: display icon if image not available
                child: scan.imagePath.isEmpty
                    ? const Icon(Icons.car_repair, color: AppColors.secondaryTextColor, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              // Scan details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.title,
                      style: AppStyles.headline3.copyWith(fontSize: 16), // Smaller headline for card title
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.description,
                      style: AppStyles.bodyText2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (scan.scanDateTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Scanned: ${scan.scanDateTime!.toLocal().toIso8601String().substring(0, 10)}', // Format date
                        style: AppStyles.smallText,
                      ),
                    ],
                    if (scan.status != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${scan.status}',
                        style: AppStyles.smallText.copyWith(
                          color: scan.status == 'No Faults' ? AppColors.successColor : AppColors.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow icon
              const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryTextColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

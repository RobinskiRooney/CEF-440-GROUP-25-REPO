// lib/widgets/mechanic_card.dart
import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final Function(Mechanic) onMessage; // Callback for message action
  final Function(Mechanic) onCall; // Callback for call action

  const MechanicCard({
    super.key,
    required this.mechanic,
    required this.onMessage,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8), // Adjusted vertical margin
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mechanic.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.lightGrey,
                  child: Icon(Icons.person, color: AppColors.greyTextColor, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible( // Use Flexible to prevent overflow
                        child: Text(
                          mechanic.name,
                          style: AppStyles.headline4.copyWith(color: AppColors.textColor), // Using AppStyles
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (mechanic.isVerified)
                        Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.successColor, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: AppStyles.smallText.copyWith(color: AppColors.successColor), // Using AppStyles
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mechanic.address,
                    style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor), // Using AppStyles
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row( // This is the row for rating, location, and now action buttons
                    children: [
                      Icon(Icons.star, color: AppColors.accentColor, size: 18), // Using AppColors
                      const SizedBox(width: 4),
                      Text(
                        mechanic.rating.toString(),
                        style: AppStyles.smallText.copyWith(color: AppColors.textColor), // Using AppStyles
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, color: AppColors.greyTextColor, size: 16), // Using AppColors
                      const SizedBox(width: 4),
                      Text(
                        mechanic.location,
                        style: AppStyles.smallText.copyWith(color: AppColors.greyTextColor), // Using AppStyles
                      ),
                      const Spacer(), // Pushes the following widgets to the end of the row
                      IconButton(
                        icon: const Icon(Icons.message_outlined, color: AppColors.primaryColor, size: 20),
                        onPressed: () => onMessage(mechanic),
                        tooltip: 'Message Mechanic',
                        visualDensity: VisualDensity.compact, // Make icon button smaller
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_outlined, color: AppColors.primaryColor, size: 20),
                        onPressed: () => onCall(mechanic),
                        tooltip: 'Call Mechanic',
                        visualDensity: VisualDensity.compact, // Make icon button smaller
                      ),
                    ],
                  ),
                  // Removed the extra SizedBox and Row that previously held the buttons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
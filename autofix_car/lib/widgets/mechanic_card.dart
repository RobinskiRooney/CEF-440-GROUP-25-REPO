import 'package:flutter/material.dart';
import 'package:autofix_car/models/mechanic.dart';
import 'package:autofix_car/constants/app_colors.dart';
import 'package:autofix_car/constants/app_styles.dart';

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final Function(Mechanic) onMessage; // Callback for WhatsApp
  final Function(Mechanic) onCall;    // Callback for Phone Call
  final Function(Mechanic)? onShare; // Optional callback for sharing

  const MechanicCard({
    super.key,
    required this.mechanic,
    required this.onMessage,
    required this.onCall,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // You might want to navigate to a detailed mechanic profile page here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${mechanic.name}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mechanic Image/Icon (Placeholder if not available from backend)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    child: mechanic.name.isNotEmpty
                        ? Text(mechanic.name[0], style: AppStyles.headline3.copyWith(color: AppColors.primaryColor))
                        : const Icon(Icons.person, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mechanic.name, style: AppStyles.headline3),
                        const SizedBox(height: 4),
                        Text(mechanic.address, style: AppStyles.bodyText2),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  Text('${mechanic.rating.toStringAsFixed(1)}', style: AppStyles.bodyText2),
                  const SizedBox(width: 8),
                  Icon(
                    mechanic.verificationStatus == 'Verified' ? Icons.verified : Icons.error_outline,
                    color: mechanic.verificationStatus == 'Verified' ? AppColors.successColor : AppColors.errorColor,
                    size: 18,
                  ),
                  Text(mechanic.verificationStatus, style: AppStyles.bodyText2),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0, // horizontal space between chips
                runSpacing: 4.0, // vertical space between lines of chips
                children: mechanic.specialties.map((specialty) => Chip(
                  label: Text(specialty, style: AppStyles.smallText),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (mechanic.phone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primaryColor),
                      onPressed: () => onCall(mechanic),
                      tooltip: 'Call ${mechanic.name}',
                    ),
                  if (mechanic.website != null && mechanic.website!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.public, color: AppColors.primaryColor),
                      onPressed: () {
                        // Implement opening website
                        // _openWebsite(mechanic.website); // Assuming _openWebsite is in MechanicsPage
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Visiting website: ${mechanic.website}')),
                        );
                      },
                      tooltip: 'Visit Website',
                    ),
                  IconButton(
                    icon: Icon(Icons.chat, color: AppColors.successColor), // WhatsApp-like icon (replace with FaIcon if using FontAwesome)
                    onPressed: () => onMessage(mechanic),
                    tooltip: 'Message on WhatsApp',
                  ),
                  if (onShare != null)
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.primaryColor),
                      onPressed: () => onShare!(mechanic),
                      tooltip: 'Share Mechanic Info',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

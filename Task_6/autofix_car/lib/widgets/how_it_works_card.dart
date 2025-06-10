// lib/widgets/how_it_works_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'How it Works',
                  style: AppStyles.headline3.copyWith(color: AppColors.textColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStep(1, 'Tap the record button to capture your engine sound.'),
            _buildStep(2, 'Ensure a quiet environment for best results.'),
            _buildStep(3, 'Wait for the AI to analyze the audio.'),
            _buildStep(4, 'Get instant diagnosis and recommended actions.'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int stepNumber, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: AppStyles.smallText.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/widgets/record_button_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class RecordButtonCard extends StatelessWidget {
  final VoidCallback onRecordTap;
  final bool isRecording;
  final String recordingDuration;

  const RecordButtonCard({
    super.key,
    required this.onRecordTap,
    required this.isRecording,
    this.recordingDuration = '00:00',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isRecording ? 'Recording...' : 'Tap to Record',
              style: AppStyles.headline3.copyWith(
                color: isRecording ? AppColors.errorColor : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recordingDuration,
              style: AppStyles.headline1.copyWith(
                color: AppColors.textColor,
                fontSize: 48,
                fontFeatures: const [FontFeature.tabularFigures()], // For consistent spacing
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRecordTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isRecording ? 100 : 120,
                height: isRecording ? 100 : 120,
                decoration: BoxDecoration(
                  color: isRecording ? AppColors.errorColor : AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: AppColors.errorColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: isRecording ? 48 : 60,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isRecording
                  ? 'Tap again to stop recording.'
                  : 'Record for 10-15 seconds for best accuracy.',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/diagnosis_result_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DiagnosisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosisResultCard({
    super.key,
    required this.result,
  });

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return AppColors.errorColor;
      case 'Medium':
        return AppColors.warningColor; // Using AppColors.warningColor
      case 'Low':
        return AppColors.successColor;
      default:
        return AppColors.secondaryTextColor;
    }
  }

  Future<void> _launchYouTubeVideo(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Could not open video: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color severityColor = _getSeverityColor(result['severity'] as String);
    bool isNormal = result['isNormal'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Severity and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result['severity'] as String,
                    style: AppStyles.bodyText2.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result['title'] as String,
                    style: AppStyles.headline3.copyWith(color: severityColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              result['description'] as String,
              style: AppStyles.bodyText1.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 16),

            // Recommended Actions / Tips Section
            if (result['tips'] != null && (result['tips'] as List).isNotEmpty) ...[
              Text(
                isNormal ? 'Maintenance Tips:' : 'Recommended Actions:',
                style: AppStyles.headline3.copyWith(fontSize: 18, color: AppColors.textColor),
              ),
              const SizedBox(height: 8),
              ...(result['tips'] as List).map<Widget>((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18, color: AppColors.successColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip as String,
                            style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
              const SizedBox(height: 16),
            ],

            // YouTube Videos Section
            if (result['youtubeVideos'] != null && (result['youtubeVideos'] as List).isNotEmpty) ...[
              Text(
                'Helpful Video Tutorials:',
                style: AppStyles.headline3.copyWith(fontSize: 18, color: AppColors.textColor),
              ),
              const SizedBox(height: 8),
              ...(result['youtubeVideos'] as List).map<Widget>((video) {
                final String videoTitle = video['title'] ?? 'No Title';
                final String videoChannel = video['channel'] ?? 'Unknown Channel';
                final String videoUrl = video['url'] ?? '';
                final String videoThumbnail = video['thumbnail'] ?? 'https://placehold.co/60x60/F0F0F0/000000?text=Video';

                return Card(
                  color: AppColors.inputFillColor,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        videoThumbnail,
                        width: 60,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 45,
                            color: AppColors.borderColor,
                            child: const Icon(Icons.videocam_outlined, color: AppColors.secondaryTextColor),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      videoTitle,
                      style: AppStyles.bodyText1.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'by $videoChannel',
                      style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
                    ),
                    trailing: const Icon(Icons.launch, color: AppColors.primaryColor),
                    onTap: () => _launchYouTubeVideo(videoUrl),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

// Added for _launchYouTubeVideo to access context for ScaffoldMessenger
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// lib/screens/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Mock data for history items
  final List<Map<String, String>> historyItems = const [
    {
      'title': '1. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '2. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '3. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '4. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '5. Why is the app not scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '6. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
    {
      'title': '7. Dashboard Light scanning',
      'description': 'If you are encountering problems while scanning your dashboard ...',
    },
  ];

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Blue background for AppBar
      elevation: 0, // No shadow
      systemOverlayStyle: SystemUiOverlayStyle.light, // For white status bar icons
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.pop(context); // Navigate back
        },
      ),
      title: const Text(
        'History',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Handle notification button press
            print('Notification button pressed on History page');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey, // Light grey background for search bar
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a history',
                    hintStyle: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor),
                    suffixIcon: Icon(Icons.mic, color: AppColors.greyTextColor),
                  ),
                  style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'History',
                style: AppStyles.headline2.copyWith(color: AppColors.textColor),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: historyItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: _buildHistoryCard(
                      context,
                      title: historyItems[index]['title']!,
                      description: historyItems[index]['description']!,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, {required String title, required String description}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.headline3.copyWith(color: AppColors.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.greyTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}

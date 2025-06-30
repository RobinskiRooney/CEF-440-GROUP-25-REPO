// widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://res.cloudinary.com/boukeng-rochinel/image/upload/v1748827632/What_All_Those_Car_Dashboard_Symbols_Mean_zxnlyj.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autofix_car/widgets/camera_overlay_scanner.dart'; // Updated import
import 'package:autofix_car/widgets/scan_button.dart';
import 'package:autofix_car/widgets/bottom_action_bar.dart';
import '../pages/scanning_result_page.dart';

class DashboardLightScanningPage extends StatefulWidget {
  const DashboardLightScanningPage({super.key});

  @override
  State<DashboardLightScanningPage> createState() => _DashboardLightScanningPageState();
}

class _DashboardLightScanningPageState extends State<DashboardLightScanningPage> {
  // No longer need _backgroundImagePath as CameraOverlayScanner provides the background
  String? _lastScannedThumbnail;

  void _onScanButtonPressed() {
    print('Scan button pressed!');
    // In a real app, this would trigger taking a picture from the camera controller
    // For now, simulate updating the thumbnail
    setState(() {
      _lastScannedThumbnail = 'https://via.placeholder.com/50x50/333333/FFFFFF?text=Scan'; // Placeholder for a scanned image thumbnail
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capturing image... (Processing coming soon!)')),
    );
  }

  void _onThumbnailTap() {
    print('Thumbnail tapped!');
    // Implement logic to view gallery or previous scans
  }

  void _onCameraTap() {
        // Navigate to main app with navbar
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ScanningResultPage()),
    );
    // Implement logic to re-capture or switch camera
  }

  void _onCheckTap() {
    print('Check button tapped!');
    // Implement logic to confirm scan or process results
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends body behind app bar for full camera view
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Camera Preview provided by CameraOverlayScanner
          Positioned.fill(
            child: CameraOverlayScanner(), // The camera feed itself is now the background
          ),
          // Content overlaid on top of the camera feed
          Column(
            children: [
              const Spacer(flex: 3), // Pushes content down below app bar
              // The CameraOverlayScanner already contains the blue border, so no need for a separate one here
              const Spacer(flex: 2), // Spacing between scanner and scan button
              ScanButton(onPressed: _onScanButtonPressed),
              const Spacer(flex: 2), // Spacing between scan button and action bar
              // BottomActionBar(
              //   onThumbnailTap: _onThumbnailTap,
              //   onCameraTap: _onCameraTap,
              //   onCheckTap: _onCheckTap,
              //   thumbnailImageUrl: _lastScannedThumbnail,
              // ),
              const Spacer(flex: 1), // Spacing above bottom nav
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 19, 72, 218), // Make app bar transparent
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light, // For white status bar icons
     
      title: const Text(
        'Dashboard Light Scanning',
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
          },
        ),
      ],
    );
  }
}
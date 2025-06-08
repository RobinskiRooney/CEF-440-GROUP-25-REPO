import 'package:autofix_car/pages/dashboard_light_scanning_page.dart';
import 'package:autofix_car/pages/engine_diagnosis_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autofix_car/constants/app_colors.dart';

import 'package:autofix_car/widgets/diagnostic_card.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 24),
            _buildScrollableDiagnosticCards(context),
            const SizedBox(height: 32),
            _buildHelpSection(context),
            const SizedBox(height: 24),
            _buildHealthOverview(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
        'Analysis',
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

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to left
      children: [
        Text(
          'Diagnostic Method',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        Text(
          'Select the method that best describes your car\'s symptoms',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontSize: 16, // Slightly reduced font size for less bulk
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildScrollableDiagnosticCards(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: IntrinsicHeight( // Ensures all cards in the row have the same height
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.78, // Adjusted width for better readability and spacing
              child: _buildDashboardCard(context),
            ),
            const SizedBox(width: 16), // Spacing between cards
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.78,
              child: _buildEngineCard(context),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.78,
              child: DiagnosticCard(
                title: 'Manual Check',
                description: 'Describe your car problem for analysis.', // More concise
                imagePath: 'images/obd_scanner.png', // Placeholder image
                benefits: const [],
                buttonText: 'Get Started', // Generic but concise
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Manual check feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context) {
    return DiagnosticCard(
      title: 'Dashboard Scan', // Very concise title
      description: 'Scan warning lights for quick ID.', // Very concise description
      imagePath: 'images/dashboard.png',
      benefits: const [],
      buttonText: 'Scan Now', // Very concise button text
      onPressed: () => _navigateToPage(context, const DashboardLightScanningPage()),
    );
  }

  Widget _buildEngineCard(BuildContext context) {
    return DiagnosticCard(
      title: 'Engine Sound', // Very concise title
      description: 'AI analyzes sounds to find issues.', // Very concise description
      imagePath: 'images/sound.png',
      benefits: const [],
      buttonText: 'Analyze Now', // Very concise button text
      onPressed: () => _navigateToPage(context, const EngineDiagnosisPage()),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Need Help Choosing?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start with dashboard scanning if warning lights are on, otherwise try engine sound diagnosis.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showExpertAdvice(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Get Expert Advice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Car Health Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthStatus(context),
            const SizedBox(height: 16),
            _buildRecentDiagnostics(context),
            const SizedBox(height: 16),
            _buildViewReportButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Status: Good',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'Last scan: Today, 10:30 AM',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDiagnostics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Diagnostics',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDiagnosticPoint(
          context,
          'No active warning lights',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildDiagnosticPoint(
          context,
          'Engine sounds normal',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildDiagnosticPoint(
          context,
          'Next service due in 3 months',
          Icons.schedule,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildDiagnosticPoint(BuildContext context, String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewReportButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => _showFullReport(context),
        icon: const Icon(Icons.arrow_forward, size: 16),
        label: const Text('View Full Report'),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // Helper methods
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showExpertAdvice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting to expert advice...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFullReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading full health report...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
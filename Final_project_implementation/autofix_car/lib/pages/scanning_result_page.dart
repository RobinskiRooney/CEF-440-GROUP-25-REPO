// lib/pages/scanning_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'dart:io'; // For File (to display captured image)
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:intl/intl.dart'; // For date formatting

import '../widgets/scan_item_card.dart'; // Import the new ScanItemCard
import '../models/scan_data.dart'; // Import the new ScanData model
import '../models/history_entry.dart'; // Import HistoryEntry for saving to history
import '../models/notification_item.dart'; // Import NotificationItem for sending notifications

// Services
import '../services/scan_service.dart'; // New service for fetching scans
import '../services/history_service.dart'; // Service for saving to history
import '../services/notification_service.dart'; // Service for sending notifications

import '../widgets/camera_overlay_scanner.dart'; // Import CameraOverlayScanner
import 'main_navigation.dart'; // Import MainNavigation for navigating back to home tab

class ScanningResultPage extends StatefulWidget {
  final String? capturedImagePath; // Field to hold the captured image path
  final ScanData? currentScanResult; // The result of the current scan

  const ScanningResultPage({
    super.key,
    this.capturedImagePath,
    this.currentScanResult, // Pass the result of the current scan
  });

  @override
  State<ScanningResultPage> createState() => _ScanningResultPageState();
}

class _ScanningResultPageState extends State<ScanningResultPage> with TickerProviderStateMixin {
  List<ScanData> _previousScans = [];
  bool _isLoadingPreviousScans = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPreviousScans();
    // Potentially save the current scan result immediately if it's a new scan
    // However, saving to history is tied to the 'Download Report' button in your requirements.
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _loadPreviousScans() async {
    setState(() => _isLoadingPreviousScans = true);
    try {
      _previousScans = await ScanService.getMyScans();
      // Sort by scanDateTime, newest first
      _previousScans.sort((a, b) => b.scanDateTime.compareTo(a.scanDateTime));
    } catch (e) {
      debugPrint('Error loading previous scans: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load previous scans: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoadingPreviousScans = false);
    }
  }

  Future<void> _downloadReport() async {
    if (widget.currentScanResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scan result to download.')),
      );
      return;
    }

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating report and saving...'),
          ],
        ),
      ),
    );

    try {
      // 1. Save to History
      final historyEntry = HistoryEntry(
        title: 'Diagnostic Scan: ${widget.currentScanResult!.title}',
        description: widget.currentScanResult!.description,
        details: 'Status: ${widget.currentScanResult!.status.toString().split('.').last}\n'
            'Scanned on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.currentScanResult!.scanDateTime)}\n'
            '${widget.currentScanResult!.metadata != null ? 'Metadata: ${widget.currentScanResult!.metadata}' : ''}',
        type: _mapScanStatusToHistoryType(widget.currentScanResult!.status),
        timestamp: widget.currentScanResult!.scanDateTime,
        severity: _mapScanStatusToSeverity(widget.currentScanResult!.status),
        // You might want to save the image path in metadata or a dedicated field in HistoryEntry
        metadata: {'originalScanId': widget.currentScanResult!.id, 'capturedImagePath': widget.capturedImagePath},
      );
      await HistoryService.createHistoryEntry(historyEntry);
      debugPrint('Scan result saved to history.');

      // 2. Generate Notification
      final notification = NotificationItem(
        userId: 'current_user_id', // Replace with actual authenticated user ID
        title: 'Scan Report Ready!',
        message: 'Your diagnostic scan "${widget.currentScanResult!.title}" report is available.',
        timestamp: DateTime.now(),
        type: 'report_download',
        imageUrl: widget.capturedImagePath, // Use the captured image for notification if desired
        data: {
          'scanId': widget.currentScanResult!.id,
          'reportType': 'PDF',
          // Potentially a link to view the report within the app or a cloud storage URL
        },
      );
      await NotificationService.createNotification(notification);
      debugPrint('Notification sent.');

      // 3. Simulate PDF Generation
      await Future.delayed(const Duration(seconds: 2)); // Simulate PDF creation time
      debugPrint('PDF report simulated.');

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated and saved!')),
        );
        _loadPreviousScans(); // Refresh previous scans list
      }
    } catch (e) {
      debugPrint('Error during report download: $e');
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: ${e.toString()}')),
        );
      }
    }
  }

  // Helper to map ScanStatus to HistoryType
  HistoryType _mapScanStatusToHistoryType(ScanStatus status) {
    switch (status) {
      case ScanStatus.faultsDetected:
      case ScanStatus.needsAttention:
        return HistoryType.engine; // Or a more specific 'diagnostic' type if available
      case ScanStatus.noFaults:
        return HistoryType.dashboard; // Successful dashboard scan
      case ScanStatus.pending:
        return HistoryType.manual; // Or a 'system' type
      case ScanStatus.unknown:
        return HistoryType.manual;
    }
  }

  // Helper to map ScanStatus to Severity
  Severity? _mapScanStatusToSeverity(ScanStatus status) {
    switch (status) {
      case ScanStatus.faultsDetected:
        return Severity.critical;
      case ScanStatus.needsAttention:
        return Severity.medium;
      case ScanStatus.noFaults:
        return Severity.low;
      case ScanStatus.pending:
      case ScanStatus.unknown:
      default:
        return null; // No specific severity
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            // Navigate back to the main navigation (e.g., home tab)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      title: const Column(
        children: [
          Text(
            'Scan Result',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Your Vehicle\'s Health Report',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to notification page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
              debugPrint('Navigate to Notification Page');
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Current Scan Result Section
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Scan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    if (widget.currentScanResult != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.currentScanResult!.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.currentScanResult!.status.toString().split('.').last.replaceAllMapped(
                              RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.currentScanResult!.statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      // Captured Image Area
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: widget.capturedImagePath != null && File(widget.capturedImagePath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(widget.capturedImagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.camera_alt, color: Colors.grey)),
                                ),
                              )
                            : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      ),
                      const SizedBox(width: 16),
                      // Scan Result Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.currentScanResult?.title ?? 'No Scan Performed',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.currentScanResult?.description ?? 'Run a scan to see results here.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            if (widget.currentScanResult != null)
                              Text(
                                'Scanned: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.currentScanResult!.scanDateTime)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              _buildActionButton(
                context: context,
                label: 'Consult a mechanic',
                icon: Icons.person_pin_outlined,
                backgroundColor: const Color(0xFF3B82F6),
                onPressed: () {
                  // TODO: Navigate to MechanicsPage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consult Mechanic (Not Implemented)')),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Scan Again',
                      icon: Icons.refresh,
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF3B82F6),
                      borderColor: const Color(0xFF3B82F6).withOpacity(0.6),
                      onPressed: () {
                        // Navigate back to camera overlay scanner
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraOverlayScanner()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Download Report',
                      icon: Icons.download,
                      backgroundColor: const Color(0xFF10B981), // Green for download
                      onPressed: widget.currentScanResult != null ? _downloadReport : null, // Disable if no scan result
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Previous Scans Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Previous Scans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: _isLoadingPreviousScans
              ? _buildLoadingState()
              : _previousScans.isEmpty
                  ? _buildEmptyState('No previous scans found. Run a diagnostic scan!')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: _previousScans.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ScanItemCard(
                            scan: _previousScans[index],
                            onTap: () => _showScanDetailSheet(_previousScans[index]),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Color? borderColor,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1.5) : BorderSide.none,
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3B82F6)),
          SizedBox(height: 16),
          Text(
            'Loading previous scans...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showScanDetailSheet(ScanData scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scan.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      image: scan.imagePath != null
                          ? DecorationImage(
                              image: NetworkImage(scan.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: scan.imagePath == null
                        ? Icon(
                            scan.statusIcon,
                            color: scan.statusColor,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(scan.scanDateTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    if (scan.metadata != null && scan.metadata!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Additional Data:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...scan.metadata!.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/models/scan_data.dart
import 'package:flutter/material.dart';

class ScanData {
  final String imagePath; // Path or URL to the scanned image/video thumbnail
  final String title;       // e.g., "Power steering problem"
  final String description; // Detailed description of the fault
  final DateTime? scanDateTime; // When the scan was performed (optional)
  final String? status; // e.g., "Faults Detected", "No Faults" (optional)

  const ScanData({
    required this.imagePath,
    required this.title,
    required this.description,
    this.scanDateTime,
    this.status,
  });

  // Example factory for JSON parsing (if you fetch real scan history)
  factory ScanData.fromJson(Map<String, dynamic> json) {
    return ScanData(
      imagePath: json['imagePath'] as String? ?? '', // Adjust to actual backend field
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'No description.',
      scanDateTime: (json['scanDateTime']?._seconds != null) ? DateTime.fromMillisecondsSinceEpoch(json['scanDateTime']._seconds * 1000) : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'title': title,
      'description': description,
      'scanDateTime': scanDateTime?.toIso8601String(), // Convert DateTime to String for JSON
      'status': status,
    };
  }
}

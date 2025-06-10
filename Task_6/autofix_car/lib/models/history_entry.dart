// lib/models/history_entry.dart
// No 'package:cloud_firestore/cloud_firestore.dart' import
// All date parsing handled from standard JSON (e.g., ISO 8601 strings)

class HistoryEntry {
  final String id; // Document ID from backend
  final String userId; // The UID of the user this history entry belongs to
  final String type; // e.g., 'Diagnostic Scan', 'Service Appointment', 'Repair Log'
  final String title; // Short title for the history entry
  final String description; // More detailed description
  final DateTime timestamp; // When the event occurred (parsed from string/int)
  final Map<String, dynamic>? details; // Optional: additional structured data (e.g., scanId)

  HistoryEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.details,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    // Attempt to parse timestamp from different JSON formats
    DateTime parsedTimestamp;
    if (json['timestamp'] is String) {
      // Assuming backend sends ISO 8601 string
      parsedTimestamp = DateTime.parse(json['timestamp'] as String);
    } else if (json['timestamp'] is int) {
      // Assuming backend sends Unix timestamp in milliseconds
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
    } else if (json['timestamp'] is Map && json['timestamp'].containsKey('_seconds')) {
      // Handling Firebase Admin SDK timestamp format from Node.js backend for existing data
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(
          json['timestamp']['_seconds'] * 1000 + (json['timestamp']['_nanoseconds'] ?? 0) ~/ 1000000);
    }
    else {
      // Fallback for unexpected formats or null
      parsedTimestamp = DateTime.now();
    }

    return HistoryEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: parsedTimestamp,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      // Send timestamp as ISO 8601 string to backend for consistency.
      // Backend will then convert to Firestore Timestamp.
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  HistoryEntry copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? details,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
    );
  }
}

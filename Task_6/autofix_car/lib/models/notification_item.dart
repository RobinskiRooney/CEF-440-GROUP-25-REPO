// lib/models/notification_item.dart
// No 'package:cloud_firestore/cloud_firestore.dart' import
// All date parsing handled from standard JSON (e.g., ISO 8601 strings)

class NotificationItem {
  final String id; // Document ID from backend
  final String userId; // The UID of the user this notification is for
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // e.g., 'alert', 'promotion', 'update'
  final Map<String, dynamic>? data; // Optional: additional data (e.g., link to a specific scan)

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
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

    return NotificationItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: parsedTimestamp,
      isRead: json['is_read'] as bool? ?? false,
      type: json['type'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'message': message,
      // Send timestamp as ISO 8601 string to backend for consistency
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'data': data,
    };
  }

  NotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}

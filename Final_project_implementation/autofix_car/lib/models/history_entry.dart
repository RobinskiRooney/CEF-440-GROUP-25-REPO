// lib/models/history_entry.dart
enum HistoryType { dashboard, engine, manual, welcome, tutorial }

enum Severity { low, medium, high, critical }

class HistoryEntry {
  // Renamed from HistoryItem
  final String?
  id; // Made nullable as it might be null before creation on backend
  final String title;
  final String description;
  final String? details;
  final HistoryType type;
  final DateTime timestamp;
  final Severity? severity;
  final Map<String, dynamic>? metadata;

  HistoryEntry({
    this.id, // Made nullable
    required this.title,
    required this.description,
    this.details,
    required this.type,
    required this.timestamp,
    this.severity,
    this.metadata,
  });

  // Factory constructor for creating a HistoryEntry from a JSON map
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String?, // Ensure ID is parsed as String
      title: json['title'] as String,
      description: json['description'] as String,
      details: json['details'] as String?,
      type: HistoryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () =>
            HistoryType.manual, // Provide a fallback if type is not found
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] != null
          ? Severity.values.firstWhere(
              (e) => e.toString().split('.').last == json['severity'],
              orElse: () => Severity.low, // Provide a fallback
            )
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Method for converting a HistoryEntry instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Usually not sent for creation, backend generates it
      'title': title,
      'description': description,
      'details': details,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity?.toString().split('.').last,
      'metadata': metadata,
    };
  }

  // Utility method to create a new HistoryEntry instance with modified fields
  HistoryEntry copyWith({
    String? id,
    String? title,
    String? description,
    String? details,
    HistoryType? type,
    DateTime? timestamp,
    Severity? severity,
    Map<String, dynamic>? metadata,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      details: details ?? this.details,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      metadata: metadata ?? this.metadata,
    );
  }
}

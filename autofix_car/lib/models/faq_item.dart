// lib/models/faq_item.dart
// No 'package:cloud_firestore/cloud_firestore.dart' import
// All date parsing handled from standard JSON (e.g., ISO 8601 strings)

class FAQItem {
  final String id; // Document ID from backend
  final String question;
  final String answer;
  final String? category; // e.g., 'General', 'Technical', 'Maintenance'
  final int? order; // For custom ordering
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['created_at'] is String) {
      parsedCreatedAt = DateTime.parse(json['created_at'] as String);
    } else if (json['created_at'] is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int);
    } else if (json['created_at'] is Map && json['created_at'].containsKey('_seconds')) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(
          json['created_at']['_seconds'] * 1000 + (json['created_at']['_nanoseconds'] ?? 0) ~/ 1000000);
    }


    DateTime? parsedUpdatedAt;
    if (json['updated_at'] is String) {
      parsedUpdatedAt = DateTime.parse(json['updated_at'] as String);
    } else if (json['updated_at'] is int) {
      parsedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int);
    } else if (json['updated_at'] is Map && json['updated_at'].containsKey('_seconds')) {
      parsedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(
          json['updated_at']['_seconds'] * 1000 + (json['updated_at']['_nanoseconds'] ?? 0) ~/ 1000000);
    }

    return FAQItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String?,
      order: (json['order'] as num?)?.toInt(),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      // Timestamps will be handled by the backend
    };
  }

  FAQItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FAQItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

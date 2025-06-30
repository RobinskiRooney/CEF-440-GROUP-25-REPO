// lib/services/faq_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/faq_item.dart'; // Import FAQItem model
import '../services/base_service.dart'; // Import BaseService (for admin ops)

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class FAQService {
  // Get all FAQs (publicly accessible)
  static Future<List<FAQItem>> getAllFAQs() async {
    final url = Uri.parse('$kBaseUrl/faqs');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Map each item, ensuring 'id' is passed to fromJson
        return data.map((jsonItem) => FAQItem.fromJson({'id': jsonItem['id'], ...jsonItem})).toList();
      } else {
        throw Exception('Failed to fetch FAQs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error or unexpected issue fetching FAQs: $e');
    }
  }

  // ADMIN ONLY: Create a new FAQ item
  static Future<FAQItem> createFAQ(FAQItem faq) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/faqs');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(faq.toJson()),
      );
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      // Update with server-assigned ID
      return faq.copyWith(id: responseData['id'] as String?);
    } else {
      throw Exception('Failed to create FAQ: ${response.statusCode} - ${response.body}');
    }
  }

  // ADMIN ONLY: Update an FAQ item
  static Future<FAQItem> updateFAQ(String faqId, Map<String, dynamic> updates) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/faqs/$faqId');
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(updates),
      );
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Ensure 'id' is present when reconstructing the object
      return FAQItem.fromJson({'id': faqId, ...responseData});
    } else {
      throw Exception('Failed to update FAQ: ${response.statusCode} - ${response.body}');
    }
  }

  // ADMIN ONLY: Delete an FAQ item
  static Future<void> deleteFAQ(String faqId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/faqs/$faqId');
      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete FAQ: ${response.statusCode} - ${response.body}');
    }
  }
}

// lib/services/history_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/history_entry.dart'; // Import HistoryEntry model
import '../services/base_service.dart'; // Import BaseService for authenticated calls

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class HistoryService {
  // Create a new history entry (e.g., after a diagnostic scan)
  static Future<HistoryEntry> createHistoryEntry(HistoryEntry entry) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/history');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(entry.toJson()),
      );
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      // Backend should return the ID and potentially other server-set fields (like timestamp)
      return entry.copyWith(
        id: responseData['id'] as String?,
        // If backend returns timestamp after creation, parse it here:
        // timestamp: DateTime.parse(responseData['timestamp'] as String),
      );
    } else {
      throw Exception('Failed to create history entry: ${response.statusCode} - ${response.body}');
    }
  }

  // Get all history entries for the authenticated user
  static Future<List<HistoryEntry>> getMyHistory() async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/history');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Map each item, ensuring 'id' is passed to fromJson
      return data.map((jsonItem) => HistoryEntry.fromJson({'id': jsonItem['id'], ...jsonItem})).toList();
    } else {
      throw Exception('Failed to fetch history: ${response.statusCode} - ${response.body}');
    }
  }

  // Get a specific history entry by ID
  static Future<HistoryEntry> getHistoryEntryById(String entryId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/history/$entryId');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      // Ensure 'id' is included in the map passed to fromJson
      return HistoryEntry.fromJson({'id': entryId, ...json.decode(response.body)});
    } else {
      throw Exception('Failed to fetch history entry: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete a history entry
  static Future<void> deleteHistoryEntry(String entryId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/history/$entryId');
      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete history entry: ${response.statusCode} - ${response.body}');
    }
  }
}

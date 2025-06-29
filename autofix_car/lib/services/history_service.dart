import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/history_entry.dart'; // Import HistoryEntry model
import '../services/base_service.dart'; // Import BaseService for authenticated calls

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class HistoryService {
  // Create a new history entry (e.g., after a diagnostic scan)
  static Future<HistoryEntry> createHistoryEntry(HistoryEntry entry) async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
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
      // Backend should return the ID and potentially other server-set fields (like timestamp, userId if not sent)
      // When creating, the backend might return the full created object, including the ID.
      // We should use that to ensure our local model is fully synchronized.
      return HistoryEntry.fromJson(responseData);
    } else {
      throw Exception(
        'Failed to create history entry: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Get all history entries for the authenticated user
  static Future<List<HistoryEntry>> getMyHistory() async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      // Assuming your backend filters history by the authenticated user's ID automatically
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
      // Map each item using the fromJson constructor directly.
      // The fromJson constructor in HistoryEntry model already handles the 'id' and 'user_id'.
      return data.map((jsonItem) => HistoryEntry.fromJson(jsonItem)).toList();
    } else {
      throw Exception(
        'Failed to fetch history: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Get a specific history entry by ID
  static Future<HistoryEntry> getHistoryEntryById(String entryId) async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
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
      // Use fromJson directly. The response body should contain all fields including 'id' and 'user_id'.
      return HistoryEntry.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to fetch history entry: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete a history entry
  static Future<void> deleteHistoryEntry(String entryId) async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      final url = Uri.parse('$kBaseUrl/history/$entryId');
      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode != 200 && response.statusCode != 204) {
      // 204 No Content is also a valid success for DELETE
      throw Exception(
        'Failed to delete history entry: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

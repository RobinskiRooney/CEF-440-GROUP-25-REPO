import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/models/mechanic.dart'; // Import Mechanic model
import './base_service.dart';

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class MechanicService {
  static Future<List<Mechanic>> getAllMechanics() async {
    final url = Uri.parse('$kBaseUrl/mechanics');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mechanic.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch mechanics: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(
        'Network error or unexpected issue fetching mechanics: $e',
      );
    }
  }

  static Future<Mechanic> getMechanicById(String mechanicId) async {
    final url = Uri.parse('$kBaseUrl/mechanics/$mechanicId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Mechanic.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to fetch mechanic: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(
        'Network error or unexpected issue fetching mechanic: $e',
      );
    }
  }

  // --- Admin-level operations (if needed, use makeAuthenticatedRequest) ---

  static Future<Mechanic> createMechanic(Mechanic mechanic) async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      final url = Uri.parse('$kBaseUrl/mechanics');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(mechanic.toJson()),
      );
    });

    if (response.statusCode == 201) {
      return Mechanic.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create mechanic: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> updateMechanic(
    String mechanicId,
    Map<String, dynamic> updates,
  ) async {
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      final url = Uri.parse('$kBaseUrl/mechanics/$mechanicId');
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
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to update mechanic: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Deletes a mechanic via the backend (admin action)
  static Future<void> deleteMechanicBackend(
    String mechanicId,
    String idToken,
  ) async {
    final url = Uri.parse(
      '$kBaseUrl/mechanics/$mechanicId',
    ); // Backend endpoint for mechanic deletion (e.g., DELETE method)
    try {
      final response = await http.delete(
        // Use DELETE method if your backend supports RESTful DELETE
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        // 200 OK or 204 No Content
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete mechanic.');
      }
    } catch (e) {
      throw Exception(
        'Network error or server unreachable during mechanic deletion: $e',
      );
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/models/diagnostic_scan.dart'; // Import DiagnosticScan model
import 'package:autofix_car/services/base_service.dart'; // Import BaseService

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class ScanService {
  static Future<DiagnosticScan> createScan(DiagnosticScan scan) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/scans');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(scan.toJson()),
      );
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      // Backend should return the ID of the newly created scan.
      // Explicitly cast to String? to match the DiagnosticScan model's id type
      return scan.copyWith(id: responseData['id'] as String?);
    } else {
      throw Exception('Failed to create scan: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<DiagnosticScan>> getVehicleScans(String vehicleId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/scans?vehicle_id=$vehicleId');
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
      return data.map((json) => DiagnosticScan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch vehicle scans: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<DiagnosticScan> getScanById(String scanId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/scans/$scanId');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return DiagnosticScan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch scan: ${response.statusCode} - ${response.body}');
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/models/vehicle.dart'; // Import your Vehicle model
import 'package:autofix_car/services/base_service.dart'; // Import BaseService

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class VehicleService {
  static Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/vehicles');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(vehicle.toJson()),
      );
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      // Backend should return the ID of the newly created vehicle
      return vehicle.copyWith(id: responseData['id'] as String);
    } else {
      throw Exception('Failed to create vehicle: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<Vehicle>> getUserVehicles() async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/vehicles');
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
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user vehicles: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Vehicle> getVehicleById(String vehicleId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/vehicles/$vehicleId');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return Vehicle.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch vehicle: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateVehicle(String vehicleId, Map<String, dynamic> updates) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/vehicles/$vehicleId');
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
      throw Exception('Failed to update vehicle: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/vehicles/$vehicleId');
      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete vehicle: ${response.statusCode} - ${response.body}');
    }
  }
}

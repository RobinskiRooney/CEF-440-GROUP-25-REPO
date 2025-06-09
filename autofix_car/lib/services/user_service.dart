import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/models/user_profile.dart'; // Import your UserProfile model
import 'package:autofix_car/services/base_service.dart'; // Import BaseService
import 'package:autofix_car/services/token_manager.dart'; // Import TokenManager for UID

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class UserService {
  static Future<UserProfile> getUserProfile() async {
    final String? uid = await TokenManager.getUid();
    if (uid == null) {
      throw Exception('User not logged in. Cannot fetch profile without UID.');
    }

    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/users/$uid');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // If profile not found, create a default one or handle as needed
      print('User profile not found, returning default. Consider implementing profile creation on first login.');
      final String? email = await TokenManager.getEmail();
      return UserProfile(uid: uid, email: email ?? 'unknown@example.com');
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(UserProfile userProfile) async {
    final String? uid = await TokenManager.getUid();
    if (uid == null) {
      throw Exception('User not logged in. Cannot update profile.');
    }

    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/users/$uid');
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(userProfile.toJson()),
      );
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user profile: ${response.statusCode} - ${response.body}');
    }
  }
}

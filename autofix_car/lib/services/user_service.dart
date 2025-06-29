// services/user_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/models/user_profile.dart'; // Ensure this model exists and is correct
import 'package:autofix_car/services/base_service.dart'; // Ensure this service exists
import 'package:autofix_car/services/token_manager.dart'; // Ensure this service exists

// Base URL for your Node.js backend.
// Accessed from environment variables loaded via flutter_dotenv.
// Make sure to define BASE_URL and ADMIN_BASE_URL in your .env file
// final String kBaseUrl =
//     dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api/auth';
// Corrected: kBaseUrl should use ADMIN_BASE_URL from .env
final String kBaseUrl =
    dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api/admin';

class UserService {
  // --- General User Profile Management ---

  static Future<UserProfile> getUserProfile() async {
    final String? uid = await TokenManager.getUid();
    if (uid == null) {
      throw Exception('User not logged in. Cannot fetch profile without UID.');
    }

    // makeAuthenticatedRequest handles getting the idToken internally
    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      final url = Uri.parse('$kBaseUrl/users/$uid');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // BaseService should add this
        },
      );
    });

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // If profile not found, return a default/empty profile
      print(
        'User profile not found, returning default. Consider implementing profile creation on first login.',
      );
      final String? email = await TokenManager.getEmail();
      return UserProfile(uid: uid, email: email ?? 'unknown@example.com');
    } else {
      throw Exception(
        'Failed to fetch user profile: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    UserProfile userProfile,
  ) async {
    final String? uid = await TokenManager.getUid();
    if (uid == null) {
      throw Exception('User not logged in. Cannot update profile.');
    }

    final response = await BaseService.makeAuthenticatedRequest((
      idToken,
    ) async {
      final url = Uri.parse('$kBaseUrl/users/$uid');
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // BaseService should add this
        },
        body: json.encode(userProfile.toJson()),
      );
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to update user profile: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // --- Admin-specific User Management ---

  // Fetches the current user's role/admin status from the backend
  // This endpoint should be protected and only return isAdmin status
  static Future<Map<String, dynamic>?> fetchUserRole(String idToken) async {
    final url = Uri.parse(
      '$kBaseUrl/user-role',
    ); // Backend endpoint to check admin status
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body); // Expects { 'isAdmin': true/false }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch user role.');
      }
    } catch (e) {
      throw Exception(
        'Network error or server unreachable during role fetch: $e',
      );
    }
  }

  // Fetches a list of all users from the backend (for admin dashboard)
  static Future<List<Map<String, dynamic>>?> getUsers(String idToken) async {
    final url = Uri.parse(
      '$kBaseUrl/users',
    ); // Backend endpoint to list all users
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch users.');
      }
    } catch (e) {
      throw Exception(
        'Network error or server unreachable during user fetch: $e',
      );
    }
  }

  // Deletes a user via the backend (admin action)
  static Future<void> deleteUserBackend(
    String userIdToDelete,
    String idToken,
  ) async {
    final url = Uri.parse(
      '$kBaseUrl/users/delete',
    ); // Backend endpoint for user deletion
    try {
      final response = await http.post(
        // Using POST for delete as per previous controller example
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'targetUserId': userIdToDelete}),
      );
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete user.');
      }
    } catch (e) {
      throw Exception(
        'Network error or server unreachable during user deletion: $e',
      );
    }
  }

//   // --- Admin-specific Mechanic Management ---

//   // Creates a new mechanic via the backend (admin action)
//   static Future<void> createMechanic(
//     Map<String, dynamic> mechanicData,
//     String idToken,
//   ) async {
//     final url = Uri.parse(
//       '$kBaseUrl/mechanics',
//     ); // Backend endpoint to create mechanic
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $idToken',
//         },
//         body: json.encode(mechanicData),
//       );
//       if (response.statusCode != 201) {
//         // 201 Created
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to create mechanic.');
//       }
//     } catch (e) {
//       throw Exception(
//         'Network error or server unreachable during mechanic creation: $e',
//       );
//     }
//   }

//   // Fetches a list of all mechanics from the backend (for admin dashboard)
//   static Future<List<Map<String, dynamic>>?> getMechanics(
//     String idToken,
//   ) async {
//     final url = Uri.parse(
//       '$kBaseUrl/mechanics',
//     ); // Backend endpoint to list all mechanics
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $idToken',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to fetch mechanics.');
//       }
//     } catch (e) {
//       throw Exception(
//         'Network error or server unreachable during mechanic fetch: $e',
//       );
//     }
//   }

//   // Deletes a mechanic via the backend (admin action)
//   static Future<void> deleteMechanicBackend(
//     String mechanicId,
//     String idToken,
//   ) async {
//     final url = Uri.parse(
//       '$kBaseUrl/mechanics/$mechanicId',
//     ); // Backend endpoint for mechanic deletion (e.g., DELETE method)
//     try {
//       final response = await http.delete(
//         // Use DELETE method if your backend supports RESTful DELETE
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $idToken',
//         },
//       );
//       if (response.statusCode != 200 && response.statusCode != 204) {
//         // 200 OK or 204 No Content
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to delete mechanic.');
//       }
//     } catch (e) {
//       throw Exception(
//         'Network error or server unreachable during mechanic deletion: $e',
//       );
//     }
//   }
}

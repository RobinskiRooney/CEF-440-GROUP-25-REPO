import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autofix_car/services/token_manager.dart';
import 'package:autofix_car/services/auth_service.dart'; // For refreshTokenViaBackend

// Base URL for your Node.js backend.
final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class BaseService {
  // Helper function to make authenticated requests, handling token refresh
  static Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String idToken) requestBuilder,
  ) async {
    String? idToken = await TokenManager.getIdToken();
    if (idToken == null) {
      throw Exception('Authentication required. No ID token found. Please log in.');
    }

    http.Response response = await requestBuilder(idToken); // Initial request

    // If unauthorized (ID token potentially expired)
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('ID Token expired or invalid. Attempting to refresh...');
      try {
        final String? newIdToken = await refreshTokenViaBackend(); // Try to get a new ID token
        if (newIdToken != null) {
          print('Token refreshed successfully. Retrying original request...');
          response = await requestBuilder(newIdToken); // Retry with the new token
        } else {
          // This case means refreshTokenViaBackend returned null (e.g., refresh token was also invalid)
          throw Exception('Failed to get new ID token during refresh. User must re-login.');
        }
      } catch (e) {
        // If refresh fails (e.g., refresh token expired, network error during refresh)
        print('Error during token refresh or retry: $e');
        await TokenManager.clearTokens(); // Force user logout by clearing tokens
        throw Exception('Session expired. Please log in again. ($e)');
      }
    }

    // If still unauthorized or forbidden after retry/refresh (e.g., truly invalid token, revoked, or permissions)
    if (response.statusCode == 401 || response.statusCode == 403) {
      await TokenManager.clearTokens(); // Force user logout for security
      throw Exception('Authentication failed or forbidden. Please log in again.');
    }

    return response;
  }
}

   import 'package:http/http.dart' as http;
   import 'dart:convert';
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   import 'package:autofix_car/services/token_manager.dart'; // Adjust import path

   // Base URL for your Node.js backend.
   // Accessed from environment variables loaded via flutter_dotenv.
   final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

 Future<Map<String, dynamic>> _handleHttpCall(
     String endpoint, Map<String, dynamic> body) async {
   final url = Uri.parse('$kBaseUrl/auth/$endpoint');
   try {
     final response = await http.post(
       url,
       headers: {'Content-Type': 'application/json'},
       body: json.encode(body),
     );

     final responseBody = json.decode(response.body);

     if (response.statusCode >= 200 && response.statusCode < 300) {
       return responseBody;
     } else {
       throw Exception(
           responseBody['message'] ?? 'An unknown error occurred.');
     }
   } catch (e) {
     throw Exception('Failed to connect to the server: $e');
   }
 }

 Future<Map<String, dynamic>> signInWithGoogleBackend(String idToken) async {
   return _handleHttpCall('google-signin', {'idToken': idToken});
 }
   /**
    * Registers a new user by calling your Node.js backend's /auth/register endpoint.
    * Returns the backend's response map on success.
    */
  Future<Map<String, dynamic>> registerUserViaBackend(
      String email, String password) async {
    return _handleHttpCall('register', {'email': email, 'password': password});
  }

   /**
    * Logs in a user by calling your Node.js backend's /auth/login endpoint.
    * Your backend verifies the password and returns the Firebase ID Token and Refresh Token.
    * This function stores these tokens securely using TokenManager.
    * Returns the full response data on success.
    */
  Future<Map<String, dynamic>> loginUserViaBackend(
      String email, String password) async {
    final responseData =
        await _handleHttpCall('login', {'email': email, 'password': password});

    final idToken = responseData['idToken'] as String?;
    final refreshToken = responseData['refreshToken'] as String?;
    final uid = responseData['uid'] as String?;
    final userEmail = responseData['email'] as String?;

    if (idToken == null ||
        refreshToken == null ||
        uid == null ||
        userEmail == null) {
      throw Exception('Login failed: Missing required data from backend.');
    }

    await TokenManager.saveTokens(
      idToken: idToken,
      refreshToken: refreshToken,
      uid: uid,
      email: userEmail,
    );

    return responseData;
  }

   /**
    * Refreshes the ID Token by sending the Refresh Token to your Node.js backend.
    * Updates the stored tokens and returns the new ID Token on success.
    */
  Future<String> refreshTokenViaBackend() async {
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available.');
    }

    try {
      final responseData =
          await _handleHttpCall('refresh-token', {'refreshToken': refreshToken});

      final newIdToken = responseData['idToken'] as String?;
      final newRefreshToken = responseData['refreshToken'] as String?;

      if (newIdToken == null) {
        throw Exception('Token refresh failed: No new ID token received.');
      }

      await TokenManager.saveTokens(
        idToken: newIdToken,
        refreshToken: newRefreshToken ?? refreshToken,
        uid: await TokenManager.getUid() ?? '',
        email: await TokenManager.getEmail() ?? '',
      );

      return newIdToken;
    } catch (e) {
      await TokenManager.clearTokens();
      throw Exception('Session expired. Please log in again.');
    }
  }
   
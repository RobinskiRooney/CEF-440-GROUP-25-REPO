   import 'package:http/http.dart' as http;
   import 'dart:convert';
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   import 'package:autofix_car/services/token_manager.dart'; // Adjust import path

   // Base URL for your Node.js backend.
   // Accessed from environment variables loaded via flutter_dotenv.
   final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

   /**
    * Registers a new user by calling your Node.js backend's /auth/register endpoint.
    * Returns the backend's response map on success.
    */
   Future<Map<String, dynamic>?> registerUserViaBackend(String email, String password) async {
     final url = Uri.parse('$kBaseUrl/auth/register');
     print('Register URL: $url');

     try {
       final response = await http.post(
         url,
         headers: {
           'Content-Type': 'application/json',
         },
         body: json.encode({
           'email': email,
           'password': password,
         }),
       );

       if (response.statusCode == 201) {
         print('Backend registration successful: ${response.body}');
         return json.decode(response.body);
       } else {
         print('Backend registration failed: ${response.statusCode}');
         print('Response body: ${response.body}');
         final Map<String, dynamic> errorData = json.decode(response.body);
         throw Exception(errorData['message'] ?? 'Unknown error during registration');
       }
     } catch (e) {
       print('Error during backend registration: $e');
       throw Exception('Network error or unexpected issue during registration: $e');
     }
   }

   /**
    * Logs in a user by calling your Node.js backend's /auth/login endpoint.
    * Your backend verifies the password and returns the Firebase ID Token and Refresh Token.
    * This function stores these tokens securely using TokenManager.
    * Returns the full response data on success.
    */
   Future<Map<String, dynamic>?> loginUserViaBackend(String email, String password) async {
     final url = Uri.parse('$kBaseUrl/auth/login');
     print('Login URL: $url');

     try {
       final response = await http.post(
         url,
         headers: {
           'Content-Type': 'application/json',
         },
         body: json.encode({
           'email': email,
           'password': password,
         }),
       );

       if (response.statusCode == 200) {
         final responseData = json.decode(response.body);
         print('Backend login successful: $responseData');

         final String? idToken = responseData['idToken'];
         final String? refreshToken = responseData['refreshToken'];
         final String? uid = responseData['uid'];
         final String? userEmail = responseData['email'];

         if (idToken != null && refreshToken != null && uid != null && userEmail != null) {
           await TokenManager.saveTokens(
             idToken: idToken,
             refreshToken: refreshToken,
             uid: uid,
             email: userEmail,
           );
           return responseData; // Contains uid, email, idToken, refreshToken
         } else {
           throw Exception('Login failed: Missing tokens or user info from backend.');
         }
       } else {
         print('Backend login failed: ${response.statusCode}');
         print('Response body: ${response.body}');
         final Map<String, dynamic> errorData = json.decode(response.body);
         throw Exception(errorData['message'] ?? 'Unknown error during login');
       }
     } catch (e) {
       print('Error during backend login: $e');
       throw Exception('Network error or unexpected issue during backend login: $e');
     }
   }

   /**
    * Refreshes the ID Token by sending the Refresh Token to your Node.js backend.
    * Updates the stored tokens and returns the new ID Token on success.
    */
   Future<String?> refreshTokenViaBackend() async {
     final String? refreshToken = await TokenManager.getRefreshToken();
     if (refreshToken == null) {
       print('No refresh token found to refresh ID token.');
       return null;
     }

     final url = Uri.parse('$kBaseUrl/auth/refresh-token');
     print('Refresh Token URL: $url');

     try {
       final response = await http.post(
         url,
         headers: {'Content-Type': 'application/json'},
         body: json.encode({'refreshToken': refreshToken}),
       );

       if (response.statusCode == 200) {
         final responseData = json.decode(response.body);
         final String? newIdToken = responseData['idToken'];
         final String? newRefreshToken = responseData['refreshToken'];

         if (newIdToken != null) {
           await TokenManager.saveTokens(
             idToken: newIdToken,
             refreshToken: newRefreshToken ?? refreshToken, // Use new refresh token if provided
             uid: await TokenManager.getUid() ?? '', // Re-save existing user info
             email: await TokenManager.getEmail() ?? '', // Re-save existing user info
           );
           print('ID Token refreshed successfully!');
           return newIdToken;
         } else {
           throw Exception('Token refresh failed: No new ID token received.');
         }
       } else {
         print('Token refresh failed: ${response.statusCode}');
         print('Response body: ${response.body}');
         final Map<String, dynamic> errorData = json.decode(response.body);
         // If refresh token is invalid or expired, force logout on client
         if (response.statusCode == 401 || response.statusCode == 403) {
           await TokenManager.clearTokens();
           print('Refresh token invalid or expired. User logged out.');
           throw Exception('Session expired. Please log in again.');
         }
         throw Exception(errorData['message'] ?? 'Unknown error during token refresh');
       }
     } catch (e) {
       print('Error refreshing token: $e');
       await TokenManager.clearTokens(); // Clear tokens on network/unexpected error during refresh
       throw Exception('Network or unexpected error during token refresh: $e');
     }
   }
   
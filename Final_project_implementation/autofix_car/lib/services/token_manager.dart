   import 'package:flutter_secure_storage/flutter_secure_storage.dart';

   // Keys for storing tokens
   const String _kIdTokenKey = 'id_token';
   const String _kRefreshTokenKey = 'refresh_token';
   const String _kUidKey = 'user_uid';
   const String _kEmailKey = 'user_email';

   class TokenManager {
     // Create a storage instance
     static const FlutterSecureStorage _storage = FlutterSecureStorage();

     // Save tokens after successful login
     static Future<void> saveTokens({
       required String idToken,
       required String refreshToken,
       required String uid,
       required String email,
     }) async {
       await _storage.write(key: _kIdTokenKey, value: idToken);
       await _storage.write(key: _kRefreshTokenKey, value: refreshToken);
       await _storage.write(key: _kUidKey, value: uid);
       await _storage.write(key: _kEmailKey, value: email);
       print('Tokens and user info saved securely.');
     }

     // Get the ID token for authenticated requests
     static Future<String?> getIdToken() async {
       return await _storage.read(key: _kIdTokenKey);
     }

     // Get the refresh token to obtain a new ID token
     static Future<String?> getRefreshToken() async {
       return await _storage.read(key: _kRefreshTokenKey);
     }

     // Get user ID
     static Future<String?> getUid() async {
       return await _storage.read(key: _kUidKey);
     }

     // Get user email
     static Future<String?> getEmail() async {
       return await _storage.read(key: _kEmailKey);
     }

     // Clear all tokens on logout
     static Future<void> clearTokens() async {
       await _storage.delete(key: _kIdTokenKey);
       await _storage.delete(key: _kRefreshTokenKey);
       await _storage.delete(key: _kUidKey);
       await _storage.delete(key: _kEmailKey);
       print('Tokens and user info cleared securely.');
     }

     // Check if a user is currently logged in (by checking for idToken existence)
     static Future<bool> isLoggedIn() async {
       final String? idToken = await _storage.read(key: _kIdTokenKey);
       return idToken != null;
     }
   }
   
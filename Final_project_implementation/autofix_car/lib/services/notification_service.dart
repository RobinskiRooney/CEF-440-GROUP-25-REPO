// lib/services/notification_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/notification_item.dart'; // Import NotificationItem model
import '../services/base_service.dart'; // Import BaseService for authenticated calls

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback.url';

class NotificationService {
  // Get all notifications for the authenticated user
  static Future<List<NotificationItem>> getMyNotifications() async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/notifications');
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
      // Map each item, ensuring 'id' is passed to fromJson
      return data.map((jsonItem) => NotificationItem.fromJson({'id': jsonItem['id'], ...jsonItem})).toList();
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode} - ${response.body}');
    }
  }

  // Mark a notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/notifications/$notificationId/read');
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/notifications/$notificationId');
      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.statusCode} - ${response.body}');
    }
  }

  // ADMIN ONLY: Create a notification (can be sent to specific user or all users)
  // This would typically be called from an admin dashboard
  static Future<NotificationItem> createNotification(NotificationItem notification) async {
    final response = await BaseService.makeAuthenticatedRequest((idToken) async {
      final url = Uri.parse('$kBaseUrl/notifications');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(notification.toJson()),
      );
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      // Update with server-assigned ID
      return notification.copyWith(id: responseData['id'] as String?);
    } else {
      throw Exception('Failed to create notification: ${response.statusCode} - ${response.body}');
    }
  }
}

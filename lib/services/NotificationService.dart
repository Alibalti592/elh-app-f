import 'dart:convert';

import 'package:elh/models/AppNotification.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl = 'https://test.muslim-connect.fr/elh-api';

  Future<List<AppNotification>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final res = await http.get(
      Uri.parse('$baseUrl/notifs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      // Cast each element to AppNotification
      return data.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<bool> respondNotif(int notifId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final res = await http.post(
      Uri.parse('$baseUrl/notif/$notifId/respond'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'action': action}),
    );

    return res.statusCode == 200;
  }
}

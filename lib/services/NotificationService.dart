import 'dart:convert';

import 'package:elh/locator.dart';
import 'package:elh/models/AppNotification.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = 'https://test.muslim-connect.fr/elh-api';
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  Future<String> getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  Future<List<AppNotification>> fetchNotifications() async {
    String token = await this.getUserToken();

    final res = await http.get(
      Uri.parse('$baseUrl/notifs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);

      // Cast each element to AppNotification
      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      print('Error fetching notifications: ${res.body}');
      throw Exception('Failed to fetch notifications');
      // print the error
    }
  }

  Future<bool> respondNotif(int notifId, String action) async {
    String token = await this.getUserToken();

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

import 'dart:convert';

import 'package:elh/locator.dart';
import 'package:elh/models/AppNotification.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = 'https://muslim-connect.fr/elh-api';
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

  Future<int> respondNotif(int notifId, String action) async {
    String token = await this.getUserToken();

    final res = await http.post(
      Uri.parse('$baseUrl/notif/$notifId/respond'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'action': action}),
    );
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');
    return res.statusCode;
  }

  Future<Map<String, dynamic>> acknowledgeMany(List<int> ids) async {
    String token = await this.getUserToken();
    final uri = Uri.parse('$baseUrl/notifs/ack');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'ids': ids}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('acknowledgeMany failed: ${res.statusCode} ${res.body}');
    }
  }
}

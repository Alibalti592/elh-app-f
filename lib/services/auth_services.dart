// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // IMPORTANT:
  // Android emulator -> host machine: http://10.0.2.2:8000
  // iOS simulator -> host machine: http://127.0.0.1:8000
  // Real device -> use your LAN IP e.g. http://192.168.1.10:8000
  static const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000');

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final _secure = const FlutterSecureStorage();
  final _dio = Dio();
  Future<void> sendTokenToBackend(String idToken) async {
    final response = await http.post(
      Uri.parse(
          "https://muslim-connect.fr/api/auth/google"), // Android emulator uses 10.0.2.2 for localhost
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Backend JWT: ${data['token']}");
      print("User: ${data['user']}");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false; // user cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google ID token is null');

      final res = await _dio.post('$baseUrl/api/auth/google/sign-in', data: {
        'idToken': idToken,
      });

      final data = res.data as Map<String, dynamic>;
      final jwt = data['token'] as String;
      await _secure.write(key: 'jwt', value: jwt);
      return true;
    } catch (e) {
      // log/handle UI error
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secure.delete(key: 'jwt');
  }

  Future<Dio> authedClient() async {
    final token = await _secure.read(key: 'jwt');
    final dio = Dio(BaseOptions(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    }));
    return dio;
  }
}

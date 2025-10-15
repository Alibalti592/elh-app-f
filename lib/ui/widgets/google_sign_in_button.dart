import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({super.key});

  // ✅ IMPORTANT: use your real client IDs
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '604698170711-sd9g9snrhl6rh430lvto1p9t7nch1qpo.apps.googleusercontent.com
', // audience
    clientId: Platform.isIOS
        ? '604698170711-2e1f7s55594v6pms7v43i1orkdrn6dh3.apps.googleusercontent.com' // iOS only
        : null,
  );

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // user cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw 'Google did not return an idToken';
      }

      final resp = await http.post(
        Uri.parse('https://test.muslim-connect.fr/elh-api/auth/google'), // 👈 match Symfony
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}), // 👈 key expected by Symfony
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final jwt = data['token'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenue ${data["user"]["name"]}")),
        );
      } else {
        final body = resp.body.isNotEmpty ? resp.body : 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion Google (${resp.statusCode}) : $body")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleSignIn(context),
      icon: Image.asset('assets/icon/google.png', height: 24, width: 24),
      label: const Text("S'inscrire avec Google"),
    );
  }
}

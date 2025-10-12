import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInButton extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return; // user cancelled

      final GoogleSignInAuthentication auth = await account.authentication;

      // Send Google token to Symfony backend
      final response = await http.post(
        Uri.parse("https://muslim-connect.fr/api/auth/google"), // backend URL
        body: {"token": auth.idToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jwt = data["token"];

        // Save JWT for future requests
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt", jwt);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenue ${data["user"]["name"]}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion Google")),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Colors.black, // 👈 set your border color here
            width: 1, // 👈 border thickness
          ),
        ),
      ),
      icon: Image.asset(
        "assets/icon/google.png",
        height: 24,
        width: 24,
      ),
      label: Text(
        "S'inscrire avec Google",
        style: TextStyle(
          fontFamily: 'inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => _handleSignIn(context),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:elh/locator.dart';
import 'package:elh/models/user.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/views/modules/user/AuthServiceWithGoogle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({super.key});
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  UserRepository _userRepository = locator<UserRepository>();
  AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  NavigationService _navigationService = locator<NavigationService>();
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();
  User? user;
  StreamController<User> userController = StreamController<User>();
  UserInfos? userInfos;
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final userData = await AuthServiceWithGoogle().signInWithGoogle();
      if (userData == null) return; // user cancelled

      final email = userData['email'];
      print('Google account email: $email');
      if (email == null) {
        throw 'Google did not return an email';
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      FlutterSecureStorage storage = const FlutterSecureStorage();
      await storage.deleteAll();
      final resp = await http.post(
        Uri.parse(
            'https://test.muslim-connect.fr/elh-api/test-api/sign-in-with-google-flutter'), // Your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        final userInfo = data['user'];
        if (data.containsKey('refreshToken')) {
          data['refresh_token'] = data['refreshToken'];
          data.remove('refreshToken');
        }
        data.remove('user');
        final jwt = data['token'] as String;
        print("Bienvenue ${userInfo["firstname"]}");
        print(data);
        //await _userInfoReactiveService.getUserInfos(cache: false);
        final jwtSecret = json.encode(data);
        final prefs = await SharedPreferences.getInstance();

        await this.saveJwtInStorage(jwtSecret);
        User fetchedUser = User.fromJwt(jwtSecret);
        userController.add(fetchedUser);
        ApiResponse apiResponse = await _userRepository.getUserInfos(jwt);
        if (apiResponse.status == 200) {
          userInfos = userInfosFromJson(apiResponse.data);
          prefs.setString('userInfos', json.encode(userInfos));
        } else {
          _errorMessageService.errorOnAPICall();
        }
        await prefs.setString('jwt_token', jwt);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenue ${userInfo["firstname"]}")),
        );
        Timer(const Duration(milliseconds: 500), () {
          _navigationService.clearStackAndShow('/');
        });
      } else {
        if (resp.statusCode == 404) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email_google', email);
          Timer(const Duration(milliseconds: 500), () {
            _navigationService.clearStackAndShow('completeRegister');
          });
        } else {
          final body = resp.body.isNotEmpty ? resp.body : 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Erreur de connexion Google (${resp.statusCode}) : $body")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          print('Google Sign-In button pressed!');
          _handleSignIn(context);
        },
        icon: Image.asset(
          'assets/icon/google.png',
          height: 24,
          width: 24,
        ),
        label: const Text(
          "Se connecter avec Google",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  saveJwtInStorage(jwt) async {
    await _secureStorage.write(key: 'jwt', value: jwt);
  }
}

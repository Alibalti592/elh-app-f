import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elh/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

class LocalAuthService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();
  final NavigationService _navigationService = locator<NavigationService>();
  bool isArleadyLoginOut = false;

  Future logoutUserLocaly() async {
    if (!isArleadyLoginOut) {
      this.isArleadyLoginOut = true;
      //clear local prefs !
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      //Clear notifications
      await _fcm.deleteToken();
      //clear token
      _secureStorage.write(key: 'jwt', value: '');
      await _navigationService.clearStackAndShow('login');
    }
  }
}

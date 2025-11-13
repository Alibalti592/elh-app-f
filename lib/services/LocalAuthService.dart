import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elh/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_core/firebase_core.dart'; // pour FirebaseException
import 'package:firebase_messaging/firebase_messaging.dart'; // pour _fcm si ce n'est pas déjà fait
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();
  final NavigationService _navigationService = locator<NavigationService>();
  bool isArleadyLoginOut = false;

  Future logoutUserLocaly() async {
    if (!isArleadyLoginOut) {
      isArleadyLoginOut = true;

      // Clear local prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear FCM notifications token (sans crasher si APNs pas prêt)
      try {
        await _fcm.deleteToken();
        print('✅ FCM token deleted');
      } on FirebaseException catch (e) {
        if (e.code == 'apns-token-not-set') {
          // Cas fréquent sur iOS quand l’APNs token n’est pas encore dispo.
          print(
            '⚠️ APNs token pas encore dispo, on ignore deleteToken(): $e',
          );
        } else {
          // Autre erreur Firebase → on log seulement
          print('⚠️ Erreur Firebase lors de deleteToken(): $e');
        }
      } catch (e) {
        // Toute autre erreur inattendue
        print('⚠️ Erreur inattendue lors de deleteToken(): $e');
      }

      // Clear JWT
      await _secureStorage.write(key: 'jwt', value: '');

      // Redirection vers login
      await _navigationService.clearStackAndShow('login');
    }
  }
}

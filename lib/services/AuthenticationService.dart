import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elh/models/user.dart';
import 'package:elh/locator.dart';
import 'package:elh/repository/NotificationRepository.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/LocalAuthService.dart';
import 'package:synchronized/synchronized.dart';

class AuthenticationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final NotificationRepository _notificationRepository = locator<NotificationRepository>();
  final ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  UserRepository _userRepository   = locator<UserRepository>();
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();
  LocalAuthService _localAuthService = locator<LocalAuthService>();
  StreamController<User> userController = StreamController<User>();
  User? user;
  int nbRefreshTry = 0;
  bool hasShownError = false;
  Lock lock = new Lock();

  Future<ApiResponse> login(String username, String password) async {
    ApiResponse apiResponse = await _userRepository.getUserJwt(username, password);
    if(apiResponse.status == 200) {
      var jwt = apiResponse.data;
      if (jwtIsToken(jwt)) {
        await this.saveJwtInStorage(jwt);
        User fetchedUser = User.fromJwt(jwt);
        user = fetchedUser;
        userController.add(fetchedUser);
        //check if eneabled ??

      }
    }
    return apiResponse;
  }

  //jwt = ['token' => 'xxxxxxx']
  Future setNewTokenForUser(jwt) async {
    if (jwtIsToken(jwt)) {
      await this.saveJwtInStorage(jwt);
      User fetchedUser = User.fromJwt(jwt);
      user = fetchedUser;
      userController.add(fetchedUser);
    }
  }

  Future<String> getUserToken() async {
    bool isLoaggedIn =  await lock.synchronized(() async {
      return await this.isloggedIn();
    });
    if(isLoaggedIn) {
      var jwt = await _secureStorage.read(key: "jwt");
      return getTokenFromJwt(jwt);
    } else {
      if(await this.isOnline()) {
        //_localAuthService.logoutUserLocaly();
      }
    }
    return "";
  }

  Future isOnline() async {
    bool isOnline = await hasNetwork();
    if(!isOnline) {
      _errorMessageService.errorShoMessage("Veuillez vérifier votre connexion internet !", title: 'Aucune connexion');
    }
    return isOnline;
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8') // Google's Public DNS
          .timeout(const Duration(seconds: 6));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false; // No internet connection
    } on TimeoutException {
      return false; // Network check timed out
    } catch (e) {
      print("Unexpected error in network check: $e");
      return false;
    }
  }

  Future<String> get jwtOrEmpty async {
    try {
      var jwt = await _secureStorage.read(key: "jwt");
      if(jwt == null) {
        return "";
      }
      return jwt;
    } catch(e) {
      return "";
    }
  }

  //used on startup
  Future<bool> isloggedIn() async {
    String jwt = await jwtOrEmpty;
    if(jwtIsToken(jwt)) {
      if(isValidToken(getTokenFromJwt(jwt))) {
        user = User.fromJwt(jwt);
        return true;
      } else {
        var hasRefresh = await refreshToken(jwt);
        if(hasRefresh) {
          return true;
        }
      }
    }
    return false;
  }

  String getTokenFromJwt(jwt) {
    return json.decode(jwt)['token'];
  }

  String getRefreshTokenFromJwt(jwt) {
    return json.decode(jwt)['refresh_token'];
  }

  bool isValidToken(token) {
    try {
      var tokenSplit = token.split(".");
      var payload = json.decode(ascii.decode(base64.decode(base64.normalize(tokenSplit[1]))));
      if(DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now())) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<dynamic> refreshToken(jwt) async {
      ApiResponse apiResponse = await _userRepository.getUserJwtFromRefreshToken(jwt);
      if(apiResponse.status == 200) {
        var jwt = apiResponse.data;
        if (jwtIsToken(jwt)) {
          if(isValidToken(getTokenFromJwt(jwt))) { // checker nouveau token
            await this.saveJwtInStorage(jwt);
            User fetchedUser = User.fromJwt(jwt);
            userController.add(fetchedUser);
            return true;
          }
        }
      }
      return false;
  }

  bool jwtIsToken(jwt) {
    if(jwt == "") {
      return false;
    }
    try {
      String token = json.decode(jwt)['token'];
      var tokenSplited = token.split(".");
      if(tokenSplited.length == 3) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  saveJwtInStorage(jwt) async {
    await _secureStorage.write(key: 'jwt', value: jwt);
  }

  clearJwtInStorage() {
    _secureStorage.write(key: 'jwt', value: '');
  }

  getUser() {
    return user;
  }

  Future logoutUser() async {
    try {
      bool isLoggedIn = await this.isloggedIn();
      if(isLoggedIn) {
        var userToken = await getUserToken(); //Token exist encore !!
        //Clear notifications
        _fcm.getToken().then((token) async {
          var fcmTokenStr = token.toString();
          //fcmTokenStr
          _notificationRepository.deleteFCMToken(fcmTokenStr, userToken);
        });
        var jwt = await _secureStorage.read(key: "jwt");
        if(jwt != null && jwt != "") {
          _userRepository.deleteRefreshToken(getRefreshTokenFromJwt(jwt), userToken);
        }
      }
    } catch(e) {}
    _localAuthService.isArleadyLoginOut = false;
    _localAuthService.logoutUserLocaly();
  }
}
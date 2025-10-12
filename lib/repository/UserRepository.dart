import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/userRegistration.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';

class UserRepository {
  final BaseApiHelper _apiHelper = locator<BaseApiHelper>();
  //AuthApiHelper ne peut pas être utilisé ici car sinon ca boucle !

  Future<dynamic> getUserJwt(String username, String password) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json' };
    final data = jsonEncode({
      'username' : username,
      'password' : password
    });
    return _apiHelper.post('/login_check', requestHeaders, data);
  }

  Future<dynamic> getUserJwtFromRefreshToken(String jwt) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json' };
    final data = jsonEncode({
      'refresh_token' : json.decode(jwt)['refresh_token']
    });
    return _apiHelper.post('/token/refresh', requestHeaders, data);
  }

  Future<ApiResponse> deleteRefreshToken(refreshTokenString, token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    var body = json.encode({ "refreshTokenString" : refreshTokenString});
    return _apiHelper.post('/delete-refresh-token', requestHeaders, body);
  }

  Future<ApiResponse> registerUser(UserRegistration userRegistration) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json' };
    var body = json.encode({ "userRegistration": userRegistration});
    return _apiHelper.post('/user-registration', requestHeaders, body);
  }

  Future<ApiResponse> getUserInfos(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _apiHelper.get('/get-user-infos', requestHeaders);
  }

  Future<ApiResponse> getProfileInfos(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _apiHelper.get('/get-profile-infos', requestHeaders);
  }

  Future<ApiResponse> deleteAccount(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    var body = json.encode({ "delete": true});
    return _apiHelper.post('/delete-account-validation', requestHeaders, body);
  }

  Future<ApiResponse> getUserSettings(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _apiHelper.get('/load-user-settings', requestHeaders);
  }

  Future<ApiResponse> markWelcomePopupAsRead(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _apiHelper.post('/disable-show-welcome', requestHeaders, null);
  }

  Future<ApiResponse> getIntroText() async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json' };
    return _apiHelper.get('/get-intro-text', requestHeaders, public: true);
  }

  Future<ApiResponse> resetPassword(email) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json' };
    return _apiHelper.get('/ini-reset-password?email=$email', requestHeaders, public: true);
  }


  Future<ApiResponse> confirmResetPassword(password, code, email) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json' };
    var body = json.encode({ "password": password, 'code': code, 'email' : email});
    return _apiHelper.post('/confirm-reset-password', requestHeaders, body, public: true);
  }

}
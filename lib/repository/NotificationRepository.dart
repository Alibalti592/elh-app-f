import 'dart:async';
import 'dart:convert';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';

class NotificationRepository {
  BaseApiHelper _apiHelper = BaseApiHelper();

  Future<ApiResponse> hasMessage(token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _apiHelper.get('/notification/has-message', requestHeaders);
  }

  Future<ApiResponse> postFCMToken(fcmToken, token, deviceIdentifier) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    var body = json.encode({ "fcmToken" : fcmToken, 'deviceId' : deviceIdentifier});
    return _apiHelper.post('/notification/post-fcm-token', requestHeaders, body);
  }

  Future<ApiResponse> deleteFCMToken(fcmToken, token) async {
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    var body = json.encode({ "fcmToken" : fcmToken});
    return _apiHelper.post('/notification/delete-fcm-token', requestHeaders, body);
  }
}
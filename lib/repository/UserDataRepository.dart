import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class UserDataRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> saveUserExtra(key, value) async {
    var map = new Map<String, dynamic>();
    map[key] = value.toString();
    return _authApiHelper.post('/save-userextra', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> canAskUserAppReview() async {
    return _authApiHelper.get('/can-ask-app-review');
  }

  Future<ApiResponse> getExportPrefs(token) async {
    return _authApiHelper.get('/v-user-load-settings');
  }

  Future<ApiResponse> loadConfidentiatlity(token) async {
    return _authApiHelper.get('/load-param-confid');
  }

  Future<ApiResponse> saveUserAccount(String userInfos, String? location, String? newEmail) async {
    var map = new Map<String, dynamic>();
    map['userInfos'] = userInfos;
    if(location != null) {
      map['location'] = location;
    }
    if(newEmail != null) {
      map['newEmail'] = newEmail;
    }
    return _authApiHelper.post('/user-save-account', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> saveUserEmail(String email, String password) async {
    var map = new Map<String, dynamic>();
    map['email'] = email.trim();
    map['password'] = password;
    return _authApiHelper.post('/user-save-email', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> saveConfid(String datas) async {
    var map = new Map<String, dynamic>();
    map['datas'] = datas;
    return _authApiHelper.post('/user-save-confid', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> savePrefExpt(String datas) async {
    var map = new Map<String, dynamic>();
    map['settings'] = datas;
    return _authApiHelper.post('/v-user-save-settings', map, type: 'x-www-form-urlencoded');
  }


  Future<ApiResponse> updatePhoto(base64Profile) async {
    var map = new Map<String, dynamic>();
    map['base64Profile'] = base64Profile;
    return _authApiHelper.post('/update-image-profile', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> removePhoto() async {
    var map = new Map<String, dynamic>();
    return _authApiHelper.post('/remove-image-profile', map, type: 'x-www-form-urlencoded');
  }

}
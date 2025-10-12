import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/maraude.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class MaraudeRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadMaraudes(String? location, distance, bool myMaraudes) async {
    String params = "?mymaraudes=true";
    if(!myMaraudes) {
       params = "?location=$location&distance=$distance";
    }
    return _authApiHelper.get('/load-maraudes$params');
  }

  Future<ApiResponse> saveMaraude(Maraude maraude) async {
    var map = new Map<String, dynamic>();
    map['maraude'] = json.encode(maraude.toJson());
    return _authApiHelper.post('/save-maraude', map, type: 'x-www-form-urlencoded');
  }

}
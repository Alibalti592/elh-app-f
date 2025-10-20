import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/mosque.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class MosqueRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadMyMosques() async {
    return _authApiHelper.get('/load-my-mosques');
  }

  Future<ApiResponse> loadMosquesDeces(Mosque mosque) async {
    return _authApiHelper.get('/load-mosque-deces?mosqueId=${mosque.id}');
  }

  Future<ApiResponse> saveMosque(Mosque mosque) async {
    var map = new Map<String, dynamic>();
    map['mosque'] = json.encode(mosque.toJson());
    return _authApiHelper.post('/save-mosque', map,
        type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> loadMosques(String location, distance) async {
    String params = "?location=$location&distance=$distance";

    return _authApiHelper.get('/load-mosques$params');
  }

  Future<ApiResponse> markFavorite(Mosque mosque) async {
    var map = new Map<String, dynamic>();
    map['mosque'] = mosque.id.toString();
    return _authApiHelper.post('/mark-favorite-mosque', map,
        type: 'x-www-form-urlencoded');
  }
}

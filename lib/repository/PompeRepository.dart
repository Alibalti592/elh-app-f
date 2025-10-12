import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/PompeDemand.dart';
import 'package:elh/models/pompe.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class PompeRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadPompes(String location, distance) async {
    String params = "?location=$location&distance=$distance";
    return _authApiHelper.get('/load-pompes$params');
  }

  Future<ApiResponse> isPf() async {
    return _authApiHelper.get('/is-pf');
  }

  Future<ApiResponse> loadMyPompes() async {
    return _authApiHelper.get('/load-my-pompes');
  }

  Future<ApiResponse> loadMyPompeDemands() async {
    return _authApiHelper.get('/load-pompe-demands');
  }

  Future<ApiResponse> savePompe(Pompe pompe) async {
    var map = new Map<String, dynamic>();
    map['pompe'] = json.encode(pompe.toJson());
    return _authApiHelper.post('/save-pompe', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> pompeAcceptDemand(PompeDemand pompe) async {
    var map = new Map<String, dynamic>();
    map['pompe'] = json.encode(pompe.toJson());
    return _authApiHelper.post('/pompe-accept-demand', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> pompeDemandLoadChat(PompeDemand pompe) async {
    var map = new Map<String, dynamic>();
    map['pompe'] = json.encode(pompe.toJson());
    return _authApiHelper.post('/pompe-demand-load-chat', map, type: 'x-www-form-urlencoded');
  }
}
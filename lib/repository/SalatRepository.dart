import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class SalatRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadSalats({passedOnly = false}) async {
    return _authApiHelper.get('/load-salats?passedOnly=$passedOnly');
  }

  Future<ApiResponse> loadSalatsNear() async {
    return _authApiHelper.get('/load-next-salats-near');
  }

  Future<ApiResponse> loadAddSalatSettings() async {
    return _authApiHelper.get('/load-salats-add-settings');
  }

  Future<ApiResponse> checkExistingSalat(Salat salat) async {
    var map = new Map<String, dynamic>();
    map['salat'] = json.encode(salat.toJson());
    return _authApiHelper.post('/check-existing-salat', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> saveSalat(Salat salat) async {
    var map = new Map<String, dynamic>();
    map['salat'] = json.encode(salat.toJson());
    return _authApiHelper.post('/save-salat', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> shareSalatToMe(Salat salat) async {
    var map = new Map<String, dynamic>();
    map['salat'] = json.encode(salat.toJson());
    return _authApiHelper.post('/share-salat-to-me', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> loadContactsShareSalat(salatId) async {
    return _authApiHelper.get('/load-contact-share-salat?salatId=$salatId');
  }

  Future<ApiResponse> shareSalatToContact(Salat salat, toUserId) async {
    var map = new Map<String, dynamic>();
    map['salat'] = json.encode(salat.toJson());
    map['toUserId'] = toUserId.toString();
    return _authApiHelper.post('/share-salat-to-contact', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteSalata(salatId) async {
    var map = new Map<String, dynamic>();
    map['salatId'] = salatId.toString();
    return _authApiHelper.post('/delete-salat', map, type: 'x-www-form-urlencoded');
  }
}
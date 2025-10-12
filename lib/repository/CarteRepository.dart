import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class CarteRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadCartes(filter) async {
    return _authApiHelper.get('/load-cartes?filter=$filter');
  }

  Future<ApiResponse> loadTextContent(carteId) async {
    return _authApiHelper.get('/load-carte-text-content?carte=$carteId');
  }

  Future<ApiResponse> loadAddCarteSettings(type) async {
    return _authApiHelper.get('/load-cartes-add-settings?type=$type');
  }

  Future<ApiResponse> loadContactsShareCarte(carteId) async {
    return _authApiHelper.get('/load-contact-share-carte?carteId=$carteId');
  }

  Future<ApiResponse> saveCarte(Carte carte) async {
    var map = new Map<String, dynamic>();
    map['carte'] = json.encode(carte.toJson());
    return _authApiHelper.post('/save-carte', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> shareCarteToContact(Carte carte, toUserId) async {
    var map = new Map<String, dynamic>();
    map['carte'] = json.encode(carte.toJson());
    map['toUserId'] = toUserId.toString();
    return _authApiHelper.post('/share-carte-to-contact', map, type: 'x-www-form-urlencoded');
  }

  //share all acontacts
  Future<ApiResponse> shareCarte(Carte carte) async {
    var map = new Map<String, dynamic>();
    map['carte'] = json.encode(carte.toJson());
    return _authApiHelper.post('/share-carte-contacts', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteCarte(Carte carte) async {
    var map = new Map<String, dynamic>();
    map['carte'] = json.encode(carte.toJson());
    return _authApiHelper.post('/delete-carte', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteShareCarte(Carte carte) async {
    var map = new Map<String, dynamic>();
    map['carte'] = json.encode(carte.toJson());
    return _authApiHelper.post('/delete-share-carte', map, type: 'x-www-form-urlencoded');
  }

}
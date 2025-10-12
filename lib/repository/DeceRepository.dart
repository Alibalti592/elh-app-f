import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class DeceRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadDeces() async {
    return _authApiHelper.get('/load-deces');
  }

  Future<ApiResponse> loadAddDeceSettings() async {
    return _authApiHelper.get('/load-deces-add-settings');
  }

  Future<ApiResponse> saveDece(Dece dece) async {
    var map = new Map<String, dynamic>();
    map['dece'] = json.encode(dece.toJson());
    return _authApiHelper.post('/save-dece', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteDece(Dece dece) async {
    var map = new Map<String, dynamic>();
    map['deceId'] = dece.id.toString();
    return _authApiHelper.post('/delete-dece', map, type: 'x-www-form-urlencoded');
  }


  Future<ApiResponse> notifyPFs(deceId) {
    var map = new Map<String, dynamic>();
    map['deceId'] = deceId;
    return _authApiHelper.post('/dece-notify-pfs', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> loadPfs(deceId) async {
    return _authApiHelper.get('/load-pompe-accept-demand?deceId=$deceId');
  }

  Future<ApiResponse> loadImams(String location, distance) async {
    String params = "?location=$location&distance=$distance";
    // print('/load-mosques$params');
    return _authApiHelper.get('/load-imams$params');
  }
}
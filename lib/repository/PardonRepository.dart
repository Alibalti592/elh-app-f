import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/pardon.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class PardonRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadPardons() async {
    return _authApiHelper.get('/load-pardons');
  }

  Future<ApiResponse> loadAddPardonSettings() async {
    return _authApiHelper.get('/load-pardons-add-settings');
  }

  Future<ApiResponse> savePardon(Pardon pardon) async {
    var map = new Map<String, dynamic>();
    map['pardon'] = json.encode(pardon.toJson());
    return _authApiHelper.post('/save-pardon', map, type: 'x-www-form-urlencoded');
  }

}
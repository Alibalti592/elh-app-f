import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class PageRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadPageContent(page) async {
    return _authApiHelper.get('/load-page-content?page=$page');
  }

  Future<ApiResponse> setHasSeeDetteInfos() async {
    var map = new Map<String, dynamic>();
    map['hassee'] = 'true';
    return _authApiHelper.post('/hasseedetteinfos', map,
        type: 'x-www-form-urlencoded');
  }
}

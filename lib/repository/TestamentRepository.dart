// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/models/maraude.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class TestamentRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadTestament() async {
    return _authApiHelper.get('/load-testament');
  }

  Future<ApiResponse> loadOthersTestament() async {
    return _authApiHelper.get('/load-others-testament');
  }

  Future<ApiResponse> loadTestamentDettes(testament) async {
    // print('/load-testament-dettes?testament=${testament.id}');
    return _authApiHelper.get('/load-testament-dettes?testament=${testament.id}');
  }

  Future<ApiResponse> saveTestament(Testament testament) async {
    var map = new Map<String, dynamic>();
    map['testament'] = json.encode(testament.toJson());
    return _authApiHelper.post('/save-testament', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> getJeun() async {
    return _authApiHelper.get('/get-jeun');
  }

  Future<ApiResponse> loadJeuntext(testament) async {
    String param = '';
    if(testament != null) {
      param = '?testament=${testament.id}';
    }
    return _authApiHelper.get('/get-jeun-string-for-testatement$param');
  }

  Future<ApiResponse> saveJeun(String jeunText, int jeunnbDays, int jeunNbDaysR, int selectedYear) async {
    var map = new Map<String, dynamic>();
    map['jeunText'] = jeunText;
    map['jeunNbDays'] = jeunnbDays.toString();
    map['jeunNbDaysR'] = jeunNbDaysR.toString();
    map['selectedYear'] = selectedYear.toString();
    return _authApiHelper.post('/save-jeun-textnbdays', map, type: 'x-www-form-urlencoded');
  }



  Future<ApiResponse> getPdfLink(Testament testament) async {
    var map = new Map<String, dynamic>();
    map['testament'] = testament.id.toString();
    return _authApiHelper.post('/testamenet-generate-pdf', map, type: 'x-www-form-urlencoded');
  }



}
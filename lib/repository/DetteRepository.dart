// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/models/maraude.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class DetteRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadDette(detteType, filter) async {
    return _authApiHelper
        .get('/load-dettes?detteType=$detteType&filter=$filter');
  }

  Future<ApiResponse> loadCurrentDettesToRefund() async {
    return _authApiHelper.get('/load-dettes-to-refund');
  }

  Future<ApiResponse> loadDettesNotRefund() async {
    return _authApiHelper.get('/load-all-user-dettes-not-refund');
  }

  Future<ApiResponse> loadDettesForTestament(Testament testament) async {
    return _authApiHelper
        .get('/load-dettes-testament?testament=${testament.id}');
  }

  Future<ApiResponse> saveDette(Map<String, dynamic> obligation) async {
    return _authApiHelper.post(
      '/save-dette',
      {'obligation': json.encode(obligation)},
      type: 'x-www-form-urlencoded',
    );
  }

  Future<ApiResponse> deleteDette(obligationId) async {
    var map = new Map<String, dynamic>();
    map['obligationId'] = obligationId.toString();
    return _authApiHelper.post('/delete-dette', map,
        type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> refundDette(obligationId, refundBack) async {
    var map = new Map<String, dynamic>();
    map['obligationId'] = obligationId.toString();
    map['refundBack'] = refundBack.toString();
    return _authApiHelper.post('/refund-dette', map,
        type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> setRelatedTo(obligationId, userId) async {
    var map = new Map<String, dynamic>();
    map['obligationId'] = obligationId.toString();
    map['userId'] = userId.toString();
    return _authApiHelper.post('/dette-set-relatedto', map,
        type: 'x-www-form-urlencoded');
  }
}

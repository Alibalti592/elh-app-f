import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class PriereRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadPrieres(DateTime? date, String? locationString) async {
    String params = "";
    if(date != null) {
      String dateString = date.toIso8601String();
      params = "?date=$dateString&location=$locationString";
    } else {
      params = "?location=$locationString";
    }

    return _authApiHelper.get('/load-prieres$params');
  }

  Future<ApiResponse> savePriereNotification(prayKey) async {
    var map = new Map<String, dynamic>();
    map['prayKey'] = prayKey;
    return _authApiHelper.post('/save-pray-notif', map, type: 'x-www-form-urlencoded');
  }

}
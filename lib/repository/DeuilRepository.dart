import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class DeuilRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadDeuil(dateString, type) async {
    return _authApiHelper.get('/load-deuil?date=$dateString&type=$type');
  }

  Future<ApiResponse> saveDeuilDate(String? dateString, ref) async {
    var map = new Map<String, dynamic>();
    if(dateString != null) {
      map['endDate'] = dateString;
    }
    map['ref'] = ref;
    return _authApiHelper.post('/save-deuil-date', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> deleteDeuilDate(String? deuilDateId) async {
    var map = new Map<String, dynamic>();
    map['deuilDateId'] = deuilDateId;
    return _authApiHelper.post('/delete-deuil-date', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> loadDeuilDates() async {
    return _authApiHelper.get('/load-deuil-dates');
  }

  Future<ApiResponse> loadDashboardDatas() async {
    return _authApiHelper.get('/load-dashboard-datas');
  }
}
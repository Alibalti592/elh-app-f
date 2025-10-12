import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class DonRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadDons() async {
    return _authApiHelper.get('/load-dons');
  }

}
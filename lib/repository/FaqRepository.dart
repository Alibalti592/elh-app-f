import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class FaqRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadFaqs() async {
    // String params = "?page=$page";
    return _authApiHelper.get('/load-faqs');
  }
  Future<ApiResponse> loadQsn() async {
    // String params = "?page=$page";
    return _authApiHelper.get('/load-qsn');
  }


}
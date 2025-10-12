import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class TodoRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadTodos() async {
    // String params = "?page=$page";
    return _authApiHelper.get('/load-todos');
  }

}
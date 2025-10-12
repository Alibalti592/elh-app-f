import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class ContactRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> getThreads(page) async {
    return _authApiHelper.get('/chat/load-threads?page=$page');
  }

  Future<ApiResponse> addMessage(value, type, id) async {
    var body = json.encode({ "message" : value, "type": type, "id" : id });
    return _authApiHelper.post('/chat-add-messagev2', body);
  }

  Future<ApiResponse> getThread(Relation relation) async {
    return _authApiHelper.get('/chat/load-thread-relation?relation=${relation.id}');
  }
}
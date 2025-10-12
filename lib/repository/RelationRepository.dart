import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';

class RelationRepository {
  final AuthApiHelper _authApiHelper = locator<AuthApiHelper>();

  Future<ApiResponse> loadRelations(searchTerm) async {
    String params = "?search=$searchTerm";
    return _authApiHelper.get('/load-relations$params');
  }

  Future<ApiResponse> loadActiveRelations() async {
    // String params = "?page=$page";
    return _authApiHelper.get('/load-active-relations');
  }

  Future<ApiResponse> searchRelations(String search) async {
    var map = new Map<String, dynamic>();
    map['search'] = search;
    return _authApiHelper.post('/search-relations', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> addRelation(String relationUserId) async {
    var map = new Map<String, dynamic>();
    map['userAdd'] = relationUserId.toString();
    return _authApiHelper.post('/add-relation', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> validateRelation(Relation relation, bool accept) async {
    var map = new Map<String, dynamic>();
    map['relation'] = relation.id.toString();
    map['accept'] = accept.toString();

    return _authApiHelper.post('/validate-relation', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> blockRelation(int relationId) async {
    var map = new Map<String, dynamic>();
    map['relationId'] = relationId.toString();
    return _authApiHelper.post('/relation-block', map, type: 'x-www-form-urlencoded');
  }

  Future<ApiResponse> sendInvitation(String email) async {
    var map = new Map<String, dynamic>();
    map['email'] = email;
    return _authApiHelper.post('/send-invitation', map, type: 'x-www-form-urlencoded');
  }

  //SHARE TESTAMENT PART
  Future<ApiResponse> loadRelationShareTestatement() async {
    return _authApiHelper.get('/load-relation-share-testatment');
  }

  Future<ApiResponse> validateShareTo(Relation relation, bool accept) async {
    var map = new Map<String, dynamic>();
    map['relation'] = relation.id.toString();
    map['accept'] = accept.toString();
    return _authApiHelper.post('/validate-share-to-testatment', map, type: 'x-www-form-urlencoded');
  }
  Future<ApiResponse> blockShareTo(int relationId) async {
    var map = new Map<String, dynamic>();
    map['relationId'] = relationId.toString();
    return _authApiHelper.post('/share-block-testatment', map, type: 'x-www-form-urlencoded');
  }

}
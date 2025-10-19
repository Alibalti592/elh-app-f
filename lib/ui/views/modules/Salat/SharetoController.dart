import 'dart:async';
import 'dart:convert';
import 'package:elh/models/Relation.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/repository/SalatRepository.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:stacked/stacked.dart';

class SharetoController extends FutureViewModel<dynamic> {
  RelationRepository _relationRepository = locator<RelationRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  SalatRepository _salatRepository = locator<SalatRepository>();
  bool isLoading = true;
  List<Relation> relations = [];
  List<Relation> relationsToValidate = [];
  int? nbRelations;
  Salat salat;
  int? currentRelationLoading;

  SharetoController(this.salat);

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse =
        await _salatRepository.loadContactsShareSalat(this.salat.id.toString());
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.relations = relationFromJson(decodeData['relations']);
      this.nbRelations = decodeData['nbRelations'];
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  Future<void> refreshDatas() async {
    this.isLoading = true;
    notifyListeners();
    this.loadDatas();
  }

  String nbRelationsLabel() {
    if (this.nbRelations == null) {
      return "";
    } else {
      return "(${this.nbRelations.toString()})";
    }
  }

  shareSalatToContact(Relation relation) async {
    this.currentRelationLoading = relation.id;
    notifyListeners();
    ApiResponse apiResponse = await _salatRepository.shareSalatToContact(
        this.salat, relation.user.id);
    if (apiResponse.status == 200) {
      relation.active = !relation.active;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.currentRelationLoading = null;
    notifyListeners();
  }
}

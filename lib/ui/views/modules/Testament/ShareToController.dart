import 'dart:async';
import 'dart:convert';
import 'package:elh/models/Relation.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/Relation/RelationView.dart';
import 'package:elh/ui/views/modules/Relation/SearchRelationView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ShareToController extends FutureViewModel<dynamic> {
  RelationRepository _relationRepository = locator<RelationRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  ValueNotifier<int> relationChangeId = ValueNotifier<int>(-1);
  bool isLoading = true;
  List<Relation> relations = [];
  int? nbShareTos;


  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _relationRepository.loadRelationShareTestatement();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.relations = relationFromJson(decodeData['relations']);
      this.nbShareTos = decodeData['nbShareTos'];
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


  String nbShareTosLabel() {
    if(this.nbShareTos == null) {
      return "";
    } else {
      return "(${this.nbShareTos.toString()})";
    }
  }

  validateShareTo(Relation relation, accept) async {
    this.relationChangeId.value = relation.id!;
    ApiResponse apiResponse = await _relationRepository.validateShareTo(relation, accept);
    if (apiResponse.status == 200) {
      relation.shareTestament = accept;
    } else {
      this.loadDatas();
      _errorMessageService.errorOnAPICall();
    }
    this.relationChangeId.value = -1;
    notifyListeners();
  }

  void goToContact() {
    _navigationService.navigateToView(SearchRelationView('updateList'))?.then((value) {
      if(value == "updateList") {
        this.loadDatas();
      }
    });
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/repository/ContactRepository.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/Relation/SearchRelationView.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class RelationController extends FutureViewModel<dynamic> {
  RelationRepository _relationRepository = locator<RelationRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  ContactRepository _contactRepository = locator<ContactRepository>();
  bool isLoading = true;
  List<Relation> relations = [];
  List<Relation> relationsToValidate = [];
  int? nbRelations;
  TextEditingController searchInputController = new TextEditingController();
  String searchTerm = "";
  bool showErrorText = false;
  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    ApiResponse apiResponse = await _relationRepository.loadRelations(this.searchTerm);
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.relations = relationFromJson(decodeData['relations']);
      this.relationsToValidate = relationFromJson(decodeData['relationsToValidate']);
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

  clearSearch() {
    searchInputController.text = '';
    this.searchTerm = '';
    this.relations = [];
    this.loadDatas();
    notifyListeners();
  }

  searchUser() async {
    if(this.searchTerm.length <= 3) {
      this.showErrorText = true;
      notifyListeners();
      await Future.delayed(Duration(seconds: 5));
      this.showErrorText = false;
      notifyListeners();
    } else {
      this.loadDatas();
    }
  }

  setSearch(value) {
    this.searchTerm = value;
    notifyListeners();
  }

  String nbRelationsLabel() {
    if(this.nbRelations == null) {
      return "";
    } else {
      return "(${this.nbRelations.toString()})";
    }
  }

  addRelation() {
    _navigationService.navigateToView(SearchRelationView('chat'))?.then((value) {
      if(value == "updateList") {
        this.loadDatas();
      }
    });
  }

  validateRelation(relation, accept) async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _relationRepository.validateRelation(relation, accept);
    if (apiResponse.status == 200) {
      this.loadDatas();
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.isLoading = false;
    notifyListeners();
  }

  blockRelation(Relation relation) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: relation.user.fullname,
        description: "Attention, la suppression d'un contact bloque l'accès à toutes les fonctionnalités. Pour le débloquer, vous devrez le recréer dans votre communauté.",
        cancelTitle: 'Annuler', confirmationTitle: 'Supprimer');
    if(confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse = await _relationRepository.blockRelation(relation.id!);
      if(apiResponse.status == 200) {
        this.loadDatas();
      } else {
        _errorMessageService.errorDefault();
      }
      this.isLoading = false;
      notifyListeners();
    }
  }

  chatWithHim(relation) async {
    ApiResponse apiResponse = await _contactRepository.getThread(relation);
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      Thread thread = Thread.fromJson(decodeData['thread']);
      _navigationService.clearTillFirstAndShow('chatThread',
          arguments : {
            "thread" : thread
      });
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }
}
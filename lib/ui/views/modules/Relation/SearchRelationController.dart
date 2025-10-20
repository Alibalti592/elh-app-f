import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/repository/ContactRepository.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SearchRelationController extends BaseViewModel {
  RelationRepository _relationRepository = locator<RelationRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  ContactRepository _contactRepository = locator<ContactRepository>();
  TextEditingController searchTextController = new TextEditingController();
  bool isLoading = false;
  bool showErrorText = false;
  bool showInfosSearch = true;
  String searchBy = 'phone';
  bool updateListcontacts = false; //callback
  List<Relation> relations = [];
  int? isAddingRelationId;
  bool hasSearchRelation = false;
  //
  bool isInviting = false;
  String backview = 'chat';

  SearchRelationController(backview) {
    this.backview = backview;
  }

  Future searchRelations() async {
    String search = searchTextController.text.trim();
    ApiResponse apiResponse = await _relationRepository.searchRelations(search);
    if (apiResponse.status == 200) {
      this.isAddingRelationId = null;
      var decodeData = json.decode(apiResponse.data);
      this.searchBy = decodeData['searchBy'];
      this.relations = relationFromJson(decodeData['relations']);
      this.hasSearchRelation = true;
      this.showInfosSearch = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.isLoading = false;
    notifyListeners();
  }

  addRelation(Relation relation) async {
    this.isAddingRelationId = relation.user.id;
    notifyListeners();
    ApiResponse apiResponse = await _relationRepository
        .addRelation(this.isAddingRelationId.toString());

    if (apiResponse.status == 200) {
      this.isAddingRelationId = null;
      relation.status = 'active';
      this.updateListcontacts = true;
      try {
        var decodeData = json.decode(apiResponse.data);
        Thread thread = Thread.fromJson(decodeData['thread']);
        if (this.backview == 'chat') {
          _navigationService.clearTillFirstAndShow('chatThread',
              arguments: {"thread": thread});
        } else {
          _navigationService.back(result: 'updateList');
        }
      } catch (e) {
        _navigationService.back(result: 'updateList');
      }
    } else if (apiResponse.status == 403) {
      this.isAddingRelationId = null;
      _errorMessageService.errorShoMessage("Désolé ce contact est introuvable");
    } else {
      this.isAddingRelationId = null;
      _errorMessageService.errorDefault();
    }
    notifyListeners();
  }

  sendInvitation() async {
    String search = searchTextController.text.trim();
    if (ValidatorHelpers.validateEmail(search) != null) {
      this.isInviting = true;
      notifyListeners();
      await Future.delayed(Duration(seconds: 5));
      this.showErrorText = false;
      notifyListeners();
    } else {
      this.showErrorText = false;
      this.isInviting = true;
      notifyListeners();
      ApiResponse apiResponse =
          await _relationRepository.sendInvitation(search);
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        this.hasSearchRelation = false;
        this.searchTextController.text = "";
        _errorMessageService.errorShoMessage(decodeData['message'],
            title: 'Invitation enovyée');
      } else {
        _errorMessageService.errorOnAPICall();
      }
      this.isInviting = false;
      notifyListeners();
    }
  }

  listPhoneContact() {
    _navigationService
        .navigateWithTransition(ListPhoneContactView(),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((contact) {
      if (contact != null && contact is Contact) {
        print(contact);
        this.searchBy = 'phone';
        if (!contact.phones.isEmpty) {
          this.searchTextController.text = contact.phones[0].number;
          if (this.searchTextController.text.length > 4) {
            this.searchRelations();
          }
        }
      }
    });
  }

  chatWithHim(relation) async {
    ApiResponse apiResponse = await _contactRepository.getThread(relation);
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      Thread thread = Thread.fromJson(decodeData['thread']);
      _navigationService
          .clearTillFirstAndShow('chatThread', arguments: {"thread": thread});
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }
}

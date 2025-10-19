import 'dart:convert';
import 'package:elh/ui/views/modules/Relation/RelationView.dart';
import 'package:flutter/cupertino.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddThreadController extends FutureViewModel<dynamic> {
  ChatRepository _chatRepository = locator<ChatRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  TextEditingController searchInputController = new TextEditingController();
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = false;
  bool userListLoading = true;
  bool isSaving = false;
  List threadTypeChoices = [];
  String? threadType;
  String? infoSelection;
  List users = [];
  bool hasMoreResults = false;
  int page = 1;
  String searchTerm = "";
  List userToAddIds = [];
  bool showErrorText = false;
  bool dataLoading = false;
  bool loadingMoreUser = false;
  Thread? thread;
  String title = "";
  bool hasSearch = false;

  AddThreadController(thread) {
    if (thread != null) {
      this.thread = thread;
      this.threadType = thread.type;
      this.title = 'Ajouter des participants';
      this.loadUsers();
    } else {
      this.title = 'Créer une conversation';
    }
    this.hasSearch = false;
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadOptions();

  Future loadOptions() async {
    this.isLoading = true;
    this.hasSearch = false;
    notifyListeners();
    ApiResponse apiResponse = await _chatRepository.getAddThreadOptions();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.threadTypeChoices = decodeData['threadTypeChoices'];
      this.infoSelection = decodeData['infoSelection'];
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  loadUsers() async {
    if (this.page == 1) {
      this.userListLoading = true;
    }
    this.hasSearch = false;
    notifyListeners();
    ApiResponse apiResponse = await _chatRepository.loadUsersToAddOnThread(
        30, this.page, this.thread, this.searchTerm);
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      if (this.page > 1) {
        this.users.addAll(decodeData['users']);
      } else {
        this.users = decodeData['users'];
      }
      this.hasMoreResults = decodeData['hasMoreResults'];
      this.userListLoading = false;
      this.loadingMoreUser = false;
      if (this.searchTerm.length != 0) {
        this.hasSearch = true;
      }
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  void goToContact() {
    _navigationService.navigateToView(RelationView());
  }

  loadMore() {
    this.page = this.page + 1;
    this.loadingMoreUser = true;
    this.loadUsers();
  }

  int getCurrentIndex() {
    if (threadType == null) {
      return 0;
    } else {
      return 1;
    }
  }

  setThreadType(val) {
    this.threadType = val;
    this.loadUsers();
    notifyListeners();
  }

  setSearch(value) {
    this.searchTerm = value;
    notifyListeners();
  }

  searchUser() async {
    this.page = 1;
    if (this.searchTerm.length <= 3) {
      this.showErrorText = true;
      notifyListeners();
      await Future.delayed(Duration(seconds: 5));
      this.showErrorText = false;
      notifyListeners();
    } else {
      this.loadUsers();
    }
  }

  clearSearch() {
    searchInputController.text = '';
    this.searchTerm = '';
    this.users = [];
    this.loadUsers();
    notifyListeners();
  }

  userIsInListToAdd(userId) {
    return this.userToAddIds.contains(userId);
  }

  addParticipant(userId) {
    if (this.threadType == 'simple') {
      this.userToAddIds.add(userId);
      this.saveThread();
    } else {
      this.userToAddIds.add(userId);
    }
    notifyListeners();
  }

  removeUser(userId) {
    this.userToAddIds.remove(userId);
    notifyListeners();
  }

  saveThread() async {
    this.isSaving = true;
    notifyListeners();
    ApiResponse apiResponse = await _chatRepository.saveThread(
        this.userToAddIds, this.threadType, this.thread);
    if (apiResponse.status == 200) {
      this.thread = Thread.fromJson(json.decode(apiResponse.data)['threadUI']);
      _navigationService.replaceWithTransition(ChatView(thread: thread!));
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving = false;
      notifyListeners();
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:elh/ui/views/modules/Relation/RelationView.dart';
import 'package:elh/ui/views/modules/Relation/SearchRelationView.dart';
import 'package:flutter/cupertino.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ContactRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/chat/AddThreadView.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ThreadsController extends FutureViewModel<dynamic> {
  ContactRepository _contactRepository= locator<ContactRepository>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  ScrollController scrollController = new ScrollController();
  List<Thread> threads = [];
  int page = 1;
  bool hasMoreThreads = false;

  bool isLoading = true;

  ThreadsController() {
    this.scrollController.addListener(_scrollListener);
  }


  @override
  Future<dynamic> futureToRun() => loadThreads();

  Future loadThreads() async {
    if(this.page == 1) {
      this.isLoading = true;
      notifyListeners();
    }
    ApiResponse apiResponse = await _contactRepository.getThreads(this.page.toString());
    if(apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      try {
        var threadsRes = List<Thread>.from(decodeData['threads'].map((thread) => Thread.fromJson(thread)));
        if(this.page == 1) {
          this.threads = threadsRes;
        } else {
          this.threads.addAll(threadsRes);
        }
        this.hasMoreThreads = decodeData['hasMoreThreads'];
        this.isLoading = false;
      } catch (e) {
        _errorMessageService.errorDefault();
      }
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  _scrollListener() {
    if(scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && this.hasMoreThreads) {
      this.page++;
      this.loadThreads();
    }
  }

  Future<void> refreshData() async {
    this.page = 1;
    this.loadThreads();
  }

  void athleteCantChatDialog() {
    _dialogService.showDialog(title: "Abonnement requis", description: "Désolé la discussion nécessite un abonnement !");
  }

  void goToAddthread() {
    _navigationService.navigateToView(AddThreadView(null));
  }

  void goToContact() {
    _navigationService.navigateToView(SearchRelationView('chat'))?.then((value) {
      this.loadThreads();
    });
  }


  void navigateToChat(thread) async {
    var result = await _navigationService.navigateTo('chatThread',
        arguments : {
          "thread" : thread
        }
    );
    if(result == 'refresh') {
      this.refreshData();
    }
  }

  void navigateCommunaute() async {
    _navigationService.navigateToView(RelationView());
  }

}
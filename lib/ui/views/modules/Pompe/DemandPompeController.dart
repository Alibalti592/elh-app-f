import 'dart:async';
import 'dart:convert';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/models/PompeDemand.dart';
import 'package:elh/repository/PompeRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DemandPompeController extends FutureViewModel<dynamic> {
  PompeRepository _pompeRepository = locator<PompeRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  ScrollController scrollController = new ScrollController();
  bool isLoading = false;
  List<PompeDemand> demands = [];
  ValueNotifier<int> isSendingId = ValueNotifier<int>(-1);

  @override
  Future<dynamic> futureToRun() => loadDemands();

  Future loadDemands() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _pompeRepository.loadMyPompeDemands();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.demands = pompeDemandsFromJson(decodeData['demands']);
    }
    this.isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    this.loadDemands();
  }

  pompeAcceptDemand(PompeDemand demand) async {
    this.isSendingId.value = demand.id!;
    ApiResponse apiResponse = await _pompeRepository.pompeAcceptDemand(demand);
    try {
      if (apiResponse.status == 200) {
        Thread thread = Thread.fromJson(json.decode(apiResponse.data)['thread']);
        _navigationService.clearTillFirstAndShowView(ChatView(thread: thread!));
      } else {
        var decodeData = json.decode(apiResponse.data);
        _errorMessageService.errorShoMessage(decodeData['message']);
      }
    } catch(e) {
      _errorMessageService.errorOnAPICall();
    }
    this.isSendingId.value = -1;
  }

  goChat(PompeDemand demand) async {
    this.isSendingId.value = demand.id!;
    ApiResponse apiResponse = await _pompeRepository.pompeDemandLoadChat(demand);
    try {
      if (apiResponse.status == 200) {
        Thread thread = Thread.fromJson(json.decode(apiResponse.data)['thread']);
        _navigationService.navigateToView(ChatView(thread: thread!));
      } else {
        var decodeData = json.decode(apiResponse.data);
        _errorMessageService.errorShoMessage(decodeData['message']);
      }
    } catch(e) {
      _errorMessageService.errorOnAPICall();
    }
    this.isSendingId.value = -1;
  }

}
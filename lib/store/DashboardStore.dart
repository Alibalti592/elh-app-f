import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/repository/DeuilRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/dateService.dart';
import 'package:flutter/cupertino.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DashboardStore with ListenableServiceMixin  {
  DateService _dateService = locator<DateService>();
  DateTime? currentStoreDate;
  DeuilRepository _deuilRepository = locator<DeuilRepository>();
  RxValue<bool> fisrtDashboardloading = RxValue(true);
  RxValue<int> pageIndex = RxValue(2);
  RxValue<PageController> pageController = RxValue(PageController());
  YoutubePlayerController? youtubecontroller1;
  YoutubePlayerController? youtubecontroller2;
  YoutubePlayerController? youtubecontroller3;
  YoutubePlayerController? youtubecontroller4;
  Timer? activeTimer;
  ValueNotifier<bool> _hasNotifMessage = ValueNotifier<bool>(false);
  get hasNotifMessage => _hasNotifMessage;

  ValueNotifier<int> _changeDashboardData = ValueNotifier<int>(0);
  get changeDashboardData => _changeDashboardData;

  ValueNotifier<int> _nbSalats = ValueNotifier<int>(0);
  get nbSalats => _nbSalats;
  ValueNotifier<int> _nbDeuils = ValueNotifier<int>(0);
  get nbDeuils => _nbDeuils;
  ValueNotifier<int> _nbOnms = ValueNotifier<int>(0);
  get nbOnms => _nbOnms;
  ValueNotifier<int> _nbJeds = ValueNotifier<int>(0);
  get nbJeds => _nbJeds;
  ValueNotifier<int> _nbAmanas = ValueNotifier<int>(0);
  get nbAmanas => _nbAmanas;

  DashboardStore() {
    this.currentStoreDate = _dateService.setTimeNull(new DateTime.now());
    listenToReactiveValues([]);
  }

  YoutubePlayerController? getYtControllerOfPage(pageKey) {
    if(pageKey == 'dette') {
      return youtubecontroller1;
    } else if(pageKey == 'deuil') {
      return youtubecontroller2;
    } else if(pageKey == 'pray') {
      return youtubecontroller3;
    } else if(pageKey == 'don') {
      return youtubecontroller4;
    }
    return null;
  }

  setYtControllerOfPage(pageKey, ytcontroller) {
    if(pageKey == 'dette') {
      this.youtubecontroller1 = ytcontroller;
    } else if(pageKey == 'deuil') {
      return youtubecontroller2 = ytcontroller;
    } else if(pageKey == 'pray') {
      return youtubecontroller3 = ytcontroller;
    } else if(pageKey == 'don') {
      return youtubecontroller4 = ytcontroller;
    }
    return null;
  }

  pauseYt(pageNum) {
    this.pauseAll();
    if(pageNum == 1 && this.youtubecontroller1 != null) {
      this.youtubecontroller1!.play();
    } else if(pageNum == 2 && this.youtubecontroller2 != null) {
      this.youtubecontroller2!.play();
    } else if(pageNum == 3 && this.youtubecontroller3 != null) {
      this.youtubecontroller3!.play();
    } else if(pageNum == 4 && this.youtubecontroller4 != null) {
      this.youtubecontroller4!.play();
    }
  }

  pauseAll() {
    if(this.youtubecontroller1 != null) {
      this.youtubecontroller1!.pause();
    }
    if(this.youtubecontroller2 != null) {
      this.youtubecontroller2!.pause();
    }
    if(this.youtubecontroller3 != null) {
      this.youtubecontroller3!.pause();
    }
    if(this.youtubecontroller4 != null) {
      this.youtubecontroller4!.pause();
    }
  }

  setFisrtLoadingDone() {
    fisrtDashboardloading.value = false;
  }

  setPageIndex(index) {
    this.pageIndex.value = index;
    this.pageController.value.jumpTo(index.toDouble());
    notifyListeners(); //imp !
  }

  cleanTimer() {
    if(this.activeTimer != null) {
      this.activeTimer!.cancel();
    }
  }

  periodicRefreshDashboard() {
    this.refreshDashboard();
    this.activeTimer = Timer.periodic(Duration(minutes: 2), (timer) async {
      this.refreshDashboard();
    });
  }

  refreshDashboard() {
    this.loadDashboarDatas();
  }

  Future loadDashboarDatas() async {
    ApiResponse apiResponse = await _deuilRepository.loadDashboardDatas();
    if (apiResponse.status == 200) {
      try {
        this._nbSalats.value = json.decode(apiResponse.data)['nbSalats'];
        this._nbDeuils.value = json.decode(apiResponse.data)['nbDeuils'];
        this._nbOnms.value = json.decode(apiResponse.data)['nbOnms'];
        this._nbJeds.value = json.decode(apiResponse.data)['nbJeds'];
        this._nbAmanas.value = json.decode(apiResponse.data)['nbAmanas'];
        this._changeDashboardData.value++;
      } catch(e) {}
    }
  }

}
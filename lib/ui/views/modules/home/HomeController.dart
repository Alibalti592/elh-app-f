import 'dart:async';
import 'package:elh/services/ChatReactiveService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/PushNotificationService.dart';
import 'package:elh/store/DashboardStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/chat/ThreadsView.dart';
import 'package:flutter/material.dart';
import 'package:observable_ish/observable_ish.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/models/userInfos.dart';
import 'package:share_plus/share_plus.dart';

class HomeController extends FutureViewModel<dynamic> {
  final PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();

  NavigationService _navigationService = locator<NavigationService>();
  ScrollController scrollController = new ScrollController();
  final ChatReactiveService _chatReactiveService =
      locator<ChatReactiveService>();
  final DashboardStore _dashboardStore = locator<DashboardStore>();
  ValueNotifier<String?> userName = ValueNotifier(null);
  List<ListenableServiceMixin> get listenableServices =>
      [_dashboardStore]; //!IMPORTANT !!!
  RxValue updateNotifier =
      RxValue<int>(0); //BETTER way to emit event to other widget !
  //ini page prieres
  ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  ValueNotifier<int> pageIndexColor = ValueNotifier<int>(0);
  PageController pageController = PageController(initialPage: 0);
  RxValue appBarLeadinWidth = RxValue<double>(60.0);

  HomeController() {
    // _dynamicLinkService.initialiseDynamicLink();
    //set au premier chargement
    if (_dashboardStore.fisrtDashboardloading.value) {
      //Push notif ini
      _pushNotificationService.initialise();
      _dashboardStore.setFisrtLoadingDone();
    }
  }

  Future<void> fetchUserName() async {
    try {
      UserInfos? infos =
          await _userInfoReactiveService.getUserInfos(cache: true);
      userName.value = infos?.fullname ?? "Utilisateur";
    } catch (e) {
      print("Error fetching user name: $e");
      userName.value = "Utilisateur";
    }
  }

  pauseYt(pageNum) {
    // print(pageNum);
    // _dashboardStore.pauseYt(pageNum);
    //in store
    // if(_dashboardStore.youtubecontroller1 != null) {
    //   _dashboardStore.youtubecontroller1!.pause();
    // }
  }
  shareApp() async {
    const text =
        "Télécharge l’application gratuite Muslim Connect pour gérer tes dettes, emprunts et testament, avec un partage sécurisé à tes proches, et reste connecté et informé des Salât al-Janaza dans ta mosquée : https://test.muslim-connect.fr/app";

    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: "Muslim Connect",
        // title: "Partager", // (optional) chooser/share-sheet title
        // sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size, // iPad/macOS popover (optional)
      ),
    );

    // (optional) handle result
    // if (result.status == ShareResultStatus.success) { ... }
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  setPageIndex(index) {
    this.pageIndex.value = index;
    this.pageIndexColor.value = index;
    this.pageController.jumpToPage(index);
    if (index == 0) {
      this.appBarLeadinWidth.value = 60.0;
    } else {
      this.appBarLeadinWidth.value = 70.0;
    }
    notifyListeners();
  }

  refreshDashboard() {
    _dashboardStore.refreshDashboard();
  }

  String getTopBarLabel() {
    if (this.pageIndex.value == 1) {
      return 'Mes comptes';
    } else if (this.pageIndex.value == 2) {
      return 'À ton côtés dans l’épreuve';
    } else if (this.pageIndex.value == 3) {
      return 'Prières';
    } else if (this.pageIndex.value == 4) {
      return 'Adoration';
    }
    return '';
  }

  Future loadDatas() async {
    await fetchUserName(); // fetch current user
  }

  displayError(e) {
    print(e);
  }

  loadMainInfos() async {
    // await _dashboardStore.iniHomeDatas();
    // notifyListeners();
  }

  Future<void> refreshData() async {
    loadMainInfos();
    this.updateNotifier.value = this.updateNotifier.value + 1;
    bool hasMessage = _chatReactiveService.chekIfMessage();
    if (hasMessage) {
      notifyListeners();
    }
  }

  navigateToChat() {
    _navigationService.navigateWithTransition(ThreadsView(title: ""),
        transition: 'rightToLeft', duration: Duration(milliseconds: 200));
  }

  openSearchLocation() {
    _navigationService.navigateWithTransition(BBLocationView(),
        transitionStyle: Transition.downToUp,
        duration: Duration(milliseconds: 200));
  }
}

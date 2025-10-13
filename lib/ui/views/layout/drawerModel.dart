import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/PompeRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/store/DashboardStore.dart';
import 'package:elh/ui/views/modules/Faq/FaqView.dart';
import 'package:elh/ui/views/modules/Mosque/MosqueView.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DrawerViewModel extends FutureViewModel<dynamic> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  final DialogService _dialogService = locator<DialogService>();
  final PompeRepository _pompeRepository = locator<PompeRepository>();
  final DashboardStore _dashboardStore = locator<DashboardStore>();
  UserInfos? userInfos;
  bool isPF = false;
  String versionName = '';
  int? topMenuIndexOpen = 0;

  @override
  Future<dynamic> futureToRun() => setUser();

  DrawerViewModel() {
    setAppVersion();
  }

  updateTopMenuIndex(newIndex) {
    this.topMenuIndexOpen = this.topMenuIndexOpen == newIndex ? null : newIndex;
    notifyListeners();
  }

  Future loadIsPf() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool cacheDataValid = await _cacheDataService.dataInCacheAndValid('isPompeOwner', 7);
    //
    // if(cacheDataValid) {
    //   bool? isPFFromCache = await prefs.getBool('isPompeOwner');
    //   if(isPFFromCache != null) {
    //     this.isPF = decodeData['isPompeOwner'];
    //   }
    // }
    ApiResponse apiResponse = await _pompeRepository.isPf();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.isPF = decodeData['isPompeOwner'];
      notifyListeners();
    }
  }

  String pfLabel() {
    if (this.isPF) {
      return 'Espace pompes funèbres';
    }
    return "Vous êtes une pompe funèbre ? Enregistrez-vous !";
  }

  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  setUser() async {
    this.loadIsPf();
    this.userInfos = await _userInfoReactiveService.getUserInfos();
    notifyListeners();
  }

  Future logout() async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: 'Déconnexion',
        description: "Vous êtes certain de vouloir vous déconnecter ?",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Confirmer');
    if (confirm?.confirmed == true) {
      _dashboardStore.fisrtDashboardloading.value = true;
      _dashboardStore.cleanTimer();
      _authenticationService.logoutUser();
    }
  }

  navigateToView(view) {
    _navigationService.navigateToView(view);
  }

  navigateToFaq() {
    _navigationService.navigateToView(FaqView());
  }

  navigateToMosque() {
    _navigationService.navigateToView(MosqueView());
  }

  navigateToViewByName(viewName, {dynamic arguments}) {
    _navigationService.navigateTo(viewName, arguments: arguments);
  }

  navigateToParameters() {
    _navigationService.navigateTo('navigationParameters',
        arguments: {"userInfos": userInfos});
  }

  navigateToViewNotDevelopped(title) {
    _navigationService
        .navigateTo('noteYetDevelopped', arguments: {"appBarTitle": title});
  }

  setAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    this.versionName = packageInfo.version;
    notifyListeners();
  }
}

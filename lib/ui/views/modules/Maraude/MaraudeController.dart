import 'dart:async';
import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/maraude.dart';
import 'package:elh/repository/MaraudeRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/Maraude/AddMaraudeView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class MaraudeController extends FutureViewModel<dynamic> {
  MaraudeRepository _maraudeRepository = locator<MaraudeRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  String title = 'Maraudes';
  bool isLoading = false;
  List<Maraude> maraudes = [];
  TextEditingController cityTextController = TextEditingController();
  Bblocation? searchLocation;
  int distance = 10;
  List<int> distances = <int>[5, 10, 20, 50, 100];
  bool myMaraudesView = false;

  @override
  Future<dynamic> futureToRun() => loadSettings();

  Future loadSettings() async {}

  Future loadDatas() async {
    String? locationString;
    if (this.searchLocation != null || this.myMaraudesView) {
      if (!myMaraudesView) {
        locationString = json.encode(this.searchLocation!.toJson());
      }
      ApiResponse apiResponse = await _maraudeRepository.loadMaraudes(
          locationString, this.distance.toString(), this.myMaraudesView);
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        this.maraudes = maraudeFromJson(json.encode(decodeData['maraudes']));
        this.isLoading = false;
      } else {
        _errorMessageService.errorOnAPICall();
      }
      notifyListeners();
    }
  }

  openSearchLocation(context) {
    _navigationService
        .navigateWithTransition(BBLocationView(),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {
      if (value == "setLocation") {
        this.maraudes = [];
        this.searchLocation = _locationStore.selectedLocation;
        if (this.searchLocation != null) {
          cityTextController.text = this.searchLocation!.city;
          this.loadDatas();
        } else {
          cityTextController.text = "";
        }
      }
    });
    //CALLBACK !!
  }

  setDistance(newDistance) {
    this.distance = newDistance;
    notifyListeners();
    this.loadDatas();
  }

  setActiveMaraude(Maraude maraude, active) {
    maraude.isExpanded = active;
    notifyListeners();
  }

  getAdresseLabel(Bblocation location) {
    return "${location.city} - ${location.region}";
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  setMyMaraudes() {
    this.myMaraudesView = true;
    this.title = 'Mes maraudes ajoutée';
    this.loadDatas();
    notifyListeners();
  }

  setAllMaraudes() {
    this.myMaraudesView = false;
    this.title = 'Maraudes';
    this.loadDatas();
    notifyListeners();
  }

  addMaraude() {
    _navigationService.navigateWithTransition(AddMaraudeView())?.then((value) {
      this.loadSettings();
    });
  }
}

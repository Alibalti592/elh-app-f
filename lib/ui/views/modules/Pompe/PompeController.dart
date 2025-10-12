import 'dart:async';
import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/pompe.dart';
import 'package:elh/repository/PompeRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/Pompe/AddPompeView.dart';
import 'package:elh/ui/views/modules/Pompe/DemandPompeView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class PompeController extends FutureViewModel<dynamic> {
  PompeRepository _pompeRepository = locator<PompeRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  bool isLoading = false;
  List<Pompe> pompes = [];
  List<Pompe> ownPompes = [];
  TextEditingController cityTextController = TextEditingController();
  Bblocation? searchLocation;
  int distance = 10;
  List<int> distances = <int> [5, 10, 20, 50, 100];
  bool isPompeOwner = false;

  @override
  Future<dynamic> futureToRun() => loadSettings();

  Future loadSettings() async {
    ApiResponse apiResponse = await _pompeRepository.loadMyPompes();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.isPompeOwner = decodeData['isPompeOwner'];
      this.ownPompes = pompeFromJson(json.encode(decodeData['pompes']));
    }
    notifyListeners();
  }


  Future loadDatas() async {
    String? locationString;
    if(this.searchLocation!= null) {
      locationString = json.encode(this.searchLocation!.toJson());
      ApiResponse apiResponse = await _pompeRepository.loadPompes(locationString, this.distance.toString());
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        this.pompes = pompeFromJson(json.encode(decodeData['pompes']));
        this.isLoading = false;
      } else {
        _errorMessageService.errorOnAPICall();
      }
      notifyListeners();
    }
  }

  openSearchLocation(context) {
    _navigationService.navigateWithTransition(BBLocationView(), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "setLocation") {
        this.pompes = [];
        this.searchLocation = _locationStore.selectedLocation;
        if(this.searchLocation != null) {
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

  setActivePompe(Pompe pompe, active) {
    pompe.isExpanded = active;
    notifyListeners();
  }

  getAdresseLabel(Bblocation location) {
    return "${location.city} - ${location.region}";
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  addPompe() {
    _navigationService.navigateWithTransition(AddPompeView())?.then((value) {
      this.loadSettings();
    });
  }

  managePompe(Pompe pompe) {
    _navigationService.navigateWithTransition(AddPompeView(pompe: pompe))?.then((value) {
      this.loadSettings();
    });
  }

  viewDemands() {
    _navigationService.navigateWithTransition(DemandPompeView())?.then((value) {});
  }

}
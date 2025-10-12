import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/models/imam.dart';
import 'package:elh/models/pardon.dart';
import 'package:elh/repository/DeceRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/dece/AddDeceView.dart';
import 'package:elh/ui/views/modules/dece/DeceDetailsView.dart';
import 'package:elh/ui/views/modules/dece/pardon/AddPardonView.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeceListController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  LocationStore _locationStore = locator<LocationStore>();
  DeceRepository _deceRepository = locator<DeceRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = false;
  List<Dece> deces = [];
  List<Pardon> pardons = [];
  List<Pardon> sharedPardons = [];
  int tabIndex = 0;
  TextEditingController cityTextController = TextEditingController();
  Bblocation? searchLocation;
  int distance = 10;
  List<int> distances = <int> [5, 10, 20, 50, 100];
  List<Imam> imams = [];

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _deceRepository.loadDeces();
    if (apiResponse.status == 200) {
      try {
        this.deces = deceFromJson(json.decode(apiResponse.data)['deces']);
        this.pardons = pardonFromJson(json.decode(apiResponse.data)['pardons']);
        this.sharedPardons = pardonFromJson(json.decode(apiResponse.data)['sharedPardons']);
      } catch(e) {
        print(e);
      }
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  addDeces() {
    _navigationService.navigateWithTransition(AddDeceView(), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "updateListe") {
        this.tabIndex = 0;
        this.loadDatas();
      }
    });
  }

  // editDece(dece) {
  //   _navigationService.navigateWithTransition(DeceView(dece: dece), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
  //     if(value == "updateListe") {
  //       this.tabIndex = 0;
  //       this.loadDatas();
  //     }
  //   });
  // }

  addPardon() {
    _navigationService.navigateWithTransition(AddPardonView(), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "updateListe") {
        this.tabIndex = 1;
        this.loadDatas();
      }
    });
  }

  editPardon(pardon) {
    _navigationService.navigateWithTransition(AddPardonView(pardon: pardon), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "updateListe") {
        this.tabIndex = 1;
        this.loadDatas();
      }
    });
  }

  expandPardon(pardon) {
    pardon.isExpanded = !pardon.isExpanded;
    notifyListeners();
  }


  openSearchLocation(context) {
    _navigationService.navigateWithTransition(BBLocationView(), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
      this.tabIndex = 2;
      if(value == "setLocation") {
        this.imams = [];
        this.searchLocation = _locationStore.selectedLocation;
        if(this.searchLocation != null) {
          cityTextController.text = this.searchLocation!.city;
          this.loadImams();
        } else {
          cityTextController.text = "";
        }
      }
    });
    //CALLBACK !!
  }

  Future loadImams() async {
    this.tabIndex = 2;
    this.isLoading = true;
    notifyListeners();
    String? locationString;
    if(this.searchLocation!= null) {
      locationString = json.encode(this.searchLocation!.toJson());
      ApiResponse apiResponse = await _deceRepository.loadImams(locationString, this.distance);
      if (apiResponse.status == 200) {
        try {
          this.imams = imamsFromJson(json.decode(apiResponse.data)['imams']);
        } catch(e) {
          print(e);
        }
        this.isLoading = false;
        notifyListeners();
      } else {
        _errorMessageService.errorOnAPICall();
      }
    }

  }

  setDistance(newDistance) {
    this.distance = newDistance;
    notifyListeners();
    this.loadImams();
  }


  setActiveImam(Imam imam, active) {
    imam.isExpanded = active;
    notifyListeners();
  }

  getAdresseLabel(Bblocation location) {
    return "${location.city} - ${location.region}";
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  goToDece(Dece dece) {
    _navigationService.navigateWithTransition(DeceDetailsView(dece), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "updateListe") {
        this.loadDatas();
      }
    });
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/repository/CarteRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteSelectTypeView.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteView.dart';
import 'package:elh/ui/views/modules/Carte/CarteCard.dart';
import 'package:elh/ui/views/modules/Carte/SharetoView.dart';
import 'package:elh/ui/views/modules/Salat/AddSalataView.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CarteListController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  CarteRepository _carteRepository = locator<CarteRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = false;
  List<Carte> cartes = [];
  List<Carte> carteShares = [];
  int tabIndex = 0;
  late BuildContext context;
  Carte? openCarte;
  String filter = 'create';
  String initialOnglet = 'create';

  CarteListController(context, openCarte, onglet) {
    this.context = context;
    this.openCarte = openCarte;
    this.filter = onglet;
    this.initialOnglet = onglet;
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _carteRepository.loadCartes(this.filter);
    if (apiResponse.status == 200) {
      try {
        this.cartes = carteFromJson(json.decode(apiResponse.data)['cartes']);
      } catch(e) {
      }
      try {
        this.carteShares = carteFromJson(json.decode(apiResponse.data)['carteShares']);
      } catch(e) {
      }
      this.isLoading = false;
      notifyListeners();
      this.openautoNewCart();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  setTabEnLoadDatas(tab) {
    if(tab == 0) {
      this.filter = 'create';
    } else if(tab == 1) {
      this.filter = 'send';
    } else {
      this.filter = 'receive';
    }
    notifyListeners();
    this.loadDatas();
  }

  void openautoNewCart() {
    if(this.openCarte != null) {
      Carte newCarte = this.openCarte!;
      this.openCarte = null;
      Navigator.of(this.context).push(
        HeroDialogRoute(
            builder: (context) => Center(
              child: (newCarte.type == 'salat' && newCarte.salat != null) ? SalatCard(salat: newCarte.salat!) : CarteCard(carte: newCarte),
            )
        ),
      );
    }
  }

  addCartes() {
    if(this.initialOnglet == 'create') {
      this._navigationService.back(result: 'updateListe');
    } else {
      _navigationService.replaceWithTransition(AddCarteSelectTypeView())?.then((value) {
        if(value == "updateListe") {
          this.loadDatas();
        }
      });
    }
  }

  editCarte(Carte carte) {
    if(carte.type == 'salat') {
      _navigationService.navigateWithTransition(AddSalatView(salat: carte.salat, fromView: 'carteList'), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
        if(value == "updateListe") {
          this.loadDatas();
        }
      });
    } else {
      _navigationService.navigateWithTransition(AddCarteView(carte: carte), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
        if(value == "updateListe") {
          this.loadDatas();
        }
      });
    }

  }

  shareCarteWhatsap(carte) async {
    this.openCarte = null;
    Navigator.of(this.context).push(
      HeroDialogRoute(
          builder: (context) => Center(
            child: (carte.type == 'salat' && carte.salat != null) ? SalatCard(salat: carte.salat!, shareDirect: true) :
            CarteCard(carte: carte, shareDirect: true),
          )
      ),
    );
  }

  //partage contacts
  shareCarte(carte) async {
    _navigationService.navigateToView(SharetoView(carte));
    // this.isLoading = true;
    // notifyListeners();
    // ApiResponse apiResponse = await _carteRepository.shareCarte(carte);
    // if (apiResponse.status == 200) {
    //   var data = json.decode(apiResponse.data);
    //   if(data.containsKey('message')) {
    //     _errorMessageService.errorShoMessage(json.decode(apiResponse.data)['message'], title: 'Carte partagée');
    //   }
    // } else {
    //   _errorMessageService.errorOnAPICall();
    // }
    // this.isLoading = false;
    // notifyListeners();
  }

  deleteCarte(carte) async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _carteRepository.deleteCarte(carte);
    if (apiResponse.status == 200) {
      this.loadDatas();
    } else {
      _errorMessageService.errorOnAPICall();
      this.isLoading = false;
      notifyListeners();
    }
  }

  deleteShareCarte(carte) async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _carteRepository.deleteShareCarte(carte);
    if (apiResponse.status == 200) {
      this.loadDatas();
    } else {
      _errorMessageService.errorOnAPICall();
      this.isLoading = false;
      notifyListeners();
    }
  }


  String getLabelType(Carte carte) {
    if(carte.type == 'death') {
      return 'au dècès';
    }
    return 'à la maladie';
  }

}
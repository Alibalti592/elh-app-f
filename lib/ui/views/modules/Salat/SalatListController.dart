import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/repository/SalatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Salat/AddSalataView.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:elh/ui/views/modules/Salat/SharetoView.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SalatListController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DialogService _dialogService = locator<DialogService>();
  SalatRepository _salatRepository = locator<SalatRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = false;
  List<Salat> salats = [];
  List<Salat> salatsOfMosque = [];
  late BuildContext context;

  SalatListController(context) {
    this.context = context;
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _salatRepository.loadSalats(passedOnly: true);
    if (apiResponse.status == 200) {
      try {
        this.salats = salatFromJson(json.decode(apiResponse.data)['salats']);
        this.salatsOfMosque =
            salatFromJson(json.decode(apiResponse.data)['salatsOfMosque']);
      } catch (e) {}
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  addSalats() {
    _navigationService
        .navigateWithTransition(AddSalatView(fromView: 'salatList'),
            transitionStyle: Transition.rightToLeft,
            duration: Duration(milliseconds: 300))
        ?.then((value) async {
      if (value is Salat) {
        await this.loadDatas();
        this.openautoNewSalatCard(value);
      }
    });
  }

  void openautoNewSalatCard(salat) {
    Navigator.of(this.context).push(
      HeroDialogRoute(builder: (context) => SalatCard(salat: salat)),
    );
  }

  editSalat(salat) {
    _navigationService
        .navigateWithTransition(
            AddSalatView(salat: salat, fromView: 'salatList'),
            transitionStyle: Transition.rightToLeft,
            duration: Duration(milliseconds: 300))
        ?.then((value) async {
      if (value is Salat) {
        await this.loadDatas();
        this.openautoNewSalatCard(value);
      }
    });
  }

  deleteSalat(salat) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: "Confirmer la suprression ?",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Supprimer');
    if (confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse = await _salatRepository.deleteSalata(salat.id);
      if (apiResponse.status == 200) {
        this.loadDatas();
      } else {
        _errorMessageService.errorDefault();
        this.isLoading = false;
        notifyListeners();
      }
    }
  }

  shareSalat(Salat salat) {
    _navigationService.navigateToView(SharetoView(salat));
  }
}

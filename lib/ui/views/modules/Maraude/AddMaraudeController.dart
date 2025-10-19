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
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddMaraudeController extends FutureViewModel<dynamic> {
  MaraudeRepository _maraudeRepository = locator<MaraudeRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  String title = "Ajouter une maraude";
  bool isLoading = false;
  bool isAlreadyRegistred = false;
  Maraude maraude = new Maraude(
      date: new DateTime.now(),
      description: "",
      online: false,
      validated: false,
      dateDisplay: "",
      isExpanded: false,
      distance: 0,
      timeDisplay: "");
  TextEditingController addressTextController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();
  String dateFormat = "EEEE dd MMMM yyyy, HH:mm";

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    if (this.maraude.id == null) {
      DateTime date = new DateTime.now();
      this.maraude.dateDisplay =
          DateFormat(this.dateFormat, 'fr_FR').format(date);
      dateController.text = this.maraude.dateDisplay!;
    }
  }

  saveMaraude() async {
    if (!this.formKey.currentState!.validate()) {
      return;
    }
    if (this.maraude.location!.lat == 0) {
      _errorMessageService.errorShoMessage("Merci de sélectonner la ville ");
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse =
        await _maraudeRepository.saveMaraude(this.maraude);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      this._navigationService.popRepeated(1);
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  openSearchLocation(context) {
    _navigationService
        .navigateWithTransition(BBLocationView(fullAdress: false),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {
      if (value == "setLocation") {
        Bblocation? newLocation = _locationStore.selectedLocation;
        if (newLocation != null) {
          this.maraude.location = newLocation;
          addressTextController.text = newLocation.label;
        }
      }
    });
    //CALLBACK !!
  }

  updateDate(DateTime date) {
    this.maraude.dateDisplay =
        DateFormat(this.dateFormat, 'fr_FR').format(date);
    this.maraude.date = date;
    dateController.text = this.maraude.dateDisplay!;
  }
}

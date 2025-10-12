import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/repository/DeceRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/dece/DeceDetailsView.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddDeceController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DeceRepository _deceRepository = locator<DeceRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  bool isLoading = false;
  Map<String, dynamic> listOptions = {};
  Map<String, dynamic> listLieux = {};
  Dece newDece = new Dece( afiliation: 'father', lieu: 'maison', firstname: '',
      lastname: '', dateDisplay: '', lieuLabel: '', afiliationLabel: '', notifPf: false, notifyMosque: false);
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  TextEditingController dateController = TextEditingController();
  TextEditingController adresse1Controller = TextEditingController();
  TextEditingController adresse2Controller = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  AddDeceController(dece) {
    if(dece != null) {
      this.newDece = dece;
      adresse1Controller.text = this.newDece.adress!.label;
      dateController.text = this.newDece.dateDisplay!;
    }
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _deceRepository.loadAddDeceSettings();
    if (apiResponse.status == 200) {
      this.listOptions = json.decode(apiResponse.data)['options'];
      this.listLieux = json.decode(apiResponse.data)['lieux'];
      if(this.newDece.id == null) {
        DateTime date = new DateTime.now();
        this.newDece.dateDisplay  = DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
        this.newDece.date = date;
        dateController.text = this.newDece.dateDisplay!;
      }
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }


  save() async {
    if(!this.formKey.currentState!.validate()) {
      return;
    }
    if(this.newDece!.adress?.lat == 0 || this.newDece!.adress?.lng == null) {
      _errorMessageService.errorShoMessage("Merci de sélectionner l'adresse");
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse = await _deceRepository.saveDece(this.newDece);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      Dece savedDece = Dece.fromJson(json.decode(apiResponse.data)['dece']);
      this._navigationService.replaceWithTransition(DeceDetailsView(savedDece));
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving.value = false;
    }
  }

  setAfiliation(key) {
    this.newDece.afiliation = key;
    notifyListeners();
  }


  setLieuType(key) {
    this.newDece.lieu = key;
    notifyListeners();
  }

  openSearchLocation(context, type) {
    _navigationService.navigateWithTransition(BBLocationView(fullAdress: true), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "setLocation" && type == 'adresse1') {
        if(_locationStore.selectedLocation != null) {
          this.newDece.adress = _locationStore.selectedLocation;
          adresse1Controller.text = _locationStore.selectedLocation!.label;
        }
      }
    });
    //CALLBACK !!
  }

  updateDate(DateTime date) {
    newDece.dateDisplay  = DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
    newDece.date = date;
    dateController.text = newDece.dateDisplay!;
  }

  updateNotif(val) {
    this.newDece.notifPf = val;
    notifyListeners();
  }
  updateNotifmosque(val) {
    this.newDece.notifyMosque = val;
    notifyListeners();
  }
}
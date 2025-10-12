import 'dart:async';
import 'dart:convert';
import 'package:elh/common/theme.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/models/mosque.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/repository/SalatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/modules/Mosque/MosqueView.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddSalatController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  SalatRepository _salatRepository = locator<SalatRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  bool isLoading = false;
  Map<String, dynamic> listAfiliations = {};
  Map<String, dynamic> listLieux = {};
  Salat newSalat = new Salat( afiliation: 'father', firstname: '', lastname: '', dateDisplay: '', afiliationLabel: '', content: '', timeDisplay: '', canEdit: true);
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  TextEditingController dateController = TextEditingController();
  TextEditingController mosqueController = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  bool manualMosque = false;
  String fromView = 'salatList';

  AddSalatController(salat, fromView) {
    this.fromView = fromView;
    if(salat != null) {
      this.newSalat = salat;
      if(this.newSalat.mosque != null) {
        mosqueController.text = this.newSalat.mosque!.name;
      }
      if(this.newSalat.mosqueName != "" && this.newSalat.mosque == null) {
        mosqueController.text = this.newSalat.mosqueName;
        this.manualMosque = true;
      }
      dateController.text = this.newSalat.dateDisplay!;
    }
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _salatRepository.loadAddSalatSettings();
    if (apiResponse.status == 200) {
      this.listAfiliations = json.decode(apiResponse.data)['options'];
      if(this.newSalat.id == null) {
        DateTime date = new DateTime.now();
        this.newSalat.dateDisplay  = DateFormat("EEEE dd MMMM yyyy  à HH:mm", 'fr_FR').format(date);
        this.newSalat.date = date;
        dateController.text = this.newSalat.dateDisplay!;
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
    this.isSaving.value = true;
    //check if salat exist
    bool createNewSalat = true;
    if(this.newSalat.id == null && !this.manualMosque) {
        ApiResponse apiResponseExistingSalat = await _salatRepository.checkExistingSalat(this.newSalat);
        var jsonDatas = json.decode(apiResponseExistingSalat.data);
        bool existSalat = jsonDatas['existSalat'];
        if(existSalat) {
          createNewSalat = false;
          String confirmPhrase = jsonDatas['confirmPhrase'];
          Salat existSalat = Salat.fromJson( json.decode(apiResponseExistingSalat.data)['salat']);
          //confirm
          var confirm = await _dialogService.showConfirmationDialog(
              title: "Salât al-Janaza existante !", description: confirmPhrase,
              cancelTitleColor: primaryColorMiddle,
              cancelTitle: "Ajouter la Salât existante", confirmationTitle: 'Créer une nouvelle Salât');
          if(confirm?.confirmed == true) {
            createNewSalat = true;
          } else {
            //ajouter à sa liste
            ApiResponse apiResponse = await _salatRepository.shareSalatToMe(existSalat);
            if (apiResponse.status == 200) {
              this.isSaving.value = false;
              var salatString = json.decode(apiResponse.data)['salat'];
              Salat salat = Salat.fromJson(salatString);
              this._navigationService.back(result: salat);
            } else {
              _errorMessageService.errorOnAPICall();
              this.isSaving.value = false;
            }
          }
      }
    }
    if(createNewSalat) {
      if(this.manualMosque) {
        this.newSalat.mosqueName = mosqueController.text;
      }
      ApiResponse apiResponse = await _salatRepository.saveSalat(this.newSalat);
      if (apiResponse.status == 200) {
        this.isSaving.value = false;
        if(this.fromView == 'salatList') {
          var salatString = json.decode(apiResponse.data)['salat'];
          Salat salat = Salat.fromJson(salatString);
          this._navigationService.back(result: salat);
        } else {
          var carteString = json.decode(apiResponse.data)['carte'];
          Carte carte = Carte.fromJson(carteString);
          this._navigationService.replaceWith('carteListView', arguments: {
            "openCarte": carte
          });
        }
      } else {
        _errorMessageService.errorOnAPICall();
        this.isSaving.value = false;
      }
    }
  }

  goBack() {
    _navigationService.back();
  }

  setAfiliation(key) {
    this.newSalat.afiliation = key;
    notifyListeners();
  }

  openSearchMosque(context) {
    _navigationService.navigateWithTransition(MosqueView(isForSelect : true), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
      if(value is Mosque) {
        this.newSalat.mosque = value;
        mosqueController.text = value.name;
      } else if(value == 'manual') {
        this.manualMosque = true;
        notifyListeners();
      }
    });
  }

  updateDate(DateTime date) {
    newSalat.dateDisplay  = DateFormat("EEEE dd MMMM yyyy  à HH:mm", 'fr_FR').format(date);
    newSalat.date = date;
    dateController.text = newSalat.dateDisplay!;
  }

  setManualMosque() {
    this.manualMosque = !this.manualMosque;
    notifyListeners();
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/pompe.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/PompeRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/home/DashboardView.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddPompeController extends FutureViewModel<dynamic> {
  PompeRepository _pompeRepository = locator<PompeRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  DialogService _dialogService = locator<DialogService>();
  final UserInfoReactiveService _userInfoReactiveService = locator<UserInfoReactiveService>();
  String title = "Mes pompes funèbres";
  bool isLoading = true;
  bool isAlreadyRegistred = false;
  Pompe? pompe;
  UserInfos? userInfos;
  TextEditingController addressTextController = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  String fullname = "";
  String? phone;
  final formKey = GlobalKey<FormState>();
  int step = 1;
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneControllerUrgence = TextEditingController();
  late PhoneNumber phoneNumber;
  PhoneNumber? phoneNumberUrgence;


  AddPompeController(pompe) {
    if(pompe != null) {
      this.step = 2;
      this.pompe = pompe;
      this.addressTextController.text = this.pompe!.location!.label;
      phoneController.text = this.pompe!.phone == null ? "" : this.pompe!.phone!;
      phoneControllerUrgence.text = this.pompe!.phoneUrgence == null ? "" : this.pompe!.phoneUrgence!;
      // phoneNumber.isoCode  =  "EN";
      // phoneNumber  = PhoneNumber(dialCode: this.pompe!.phonePrefix);
      String? isocode = PhoneNumber.getISO2CodeByPrefix(this.pompe!.phonePrefix);
      if(isocode == null) {
        isocode = 'FR';
      }
      phoneNumber  = PhoneNumber(isoCode: isocode);
      String? isocode2 = PhoneNumber.getISO2CodeByPrefix(this.pompe!.phoneUrgencePrefix);
      if(isocode2 == null) {
        isocode2 = 'FR';
      }
      phoneNumberUrgence  = PhoneNumber(isoCode: isocode2);
    } else {
      this.step = 1;
      Bblocation location = new Bblocation(label: "", displayLabel: "", lat: 0, lng: 0, city: "", postcode: "", citycode: "", region: "", adress: "");
      this.pompe = new Pompe(name: "", description: "", online: false, validated: false, isExpanded: false, distance: 0, location: location);
      phoneNumber  = PhoneNumber(isoCode: 'FR');
      phoneNumberUrgence  = PhoneNumber(isoCode: 'FR');
    }
    this.isLoading = false;
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.userInfos = await _userInfoReactiveService.getUserInfos();
    if(this.userInfos != null) {
      this.phone = this.userInfos?.phone;
      this.fullname = this.userInfos!.fullname;
    }
  }

  showForm() {
    this.step = 2;
    notifyListeners();
  }

  savePompe() async {
    if(!this.formKey.currentState!.validate()) {
      return;
    }
    if(this.pompe!.location!.lat == 0 || this.pompe!.location!.city == null) {
      _errorMessageService.errorShoMessage("Merci de sélectionner l'adresse");
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse = await _pompeRepository.savePompe(this.pompe!);
    if (apiResponse.status == 200) {
      await this._dialogService.showDialog(title: 'Demande prise en compte',
          description:"Assalem alaykoum, l’inscription de votre pompe funèbre sera effective après la validation de l’équipe Muslim Connect. Une notification vous sera envoyée in sha allah.");
      this._navigationService.clearStackAndShow('/');
      this.isSaving.value = false;
    } else {
      this.isSaving.value = false;
      _errorMessageService.errorOnAPICall();
    }
  }

  openSearchLocation(context) {
    _navigationService.navigateWithTransition(BBLocationView(fullAdress: true), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "setLocation") {
        Bblocation? newLocation = _locationStore.selectedLocation;
        if(newLocation != null) {
          this.pompe!.location = newLocation;
          addressTextController.text = newLocation!.label;
        }
      }
    });
    //CALLBACK !!
  }

  setPhoneNumber(PhoneNumber phoneNumber) {
    if(this.pompe != null) {
      if(phoneNumber.parseNumber() != this.pompe!.phone) { //fix multiple updates
        this.pompe!.phone = phoneNumber.parseNumber();
        this.pompe!.phonePrefix = phoneNumber.dialCode !;
        this.phoneNumber = phoneNumber;
        notifyListeners();
      }
    }
  }

  setPhoneNumberUrgence(PhoneNumber phoneNumber) {
    if(this.pompe != null) {
      if(phoneNumber.parseNumber() != this.pompe!.phoneUrgence) { //fix multiple updates
        this.pompe!.phoneUrgence = phoneNumber.parseNumber();
        this.pompe!.phoneUrgencePrefix = phoneNumber.dialCode !;
        this.phoneNumberUrgence = phoneNumber;
        notifyListeners();
      }
    }
  }

}
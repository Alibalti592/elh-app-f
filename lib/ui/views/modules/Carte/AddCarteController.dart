import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/models/carteText.dart';
import 'package:elh/repository/CarteRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/modules/Carte/CarteListView.dart';
import 'package:elh/ui/views/modules/Mosque/MosqueView.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddCarteController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  CarteRepository _carteRepository = locator<CarteRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  bool isLoading = false;
  Map<String, dynamic> listAfiliations = {};
  Map<String, dynamic> listLieux = {};
  Carte newCarte = new Carte(
      afiliation: 'father',
      firstname: '',
      lastname: '',
      dateDisplay: '',
      afiliationLabel: '',
      content: '',
      canEdit: true);
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  TextEditingController dateController = TextEditingController();
  TextEditingController mosqueController = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  ValueNotifier<int> updatedtext = ValueNotifier<int>(0);
  List<CarteText> carteTexts = [];

  TextEditingController phoneController = TextEditingController();
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'FR');

  AddCarteController(carte) {
    if (carte != null) {
      this.newCarte = carte;
      dateController.text = this.newCarte.dateDisplay!;
      phoneController.text = this.newCarte.phone;
      this.setIniPhoneNumber();
    }
  }

  setIniPhoneNumber() async {
    phoneNumber = PhoneNumber(
        isoCode: PhoneNumber.getISO2CodeByPrefix(this.newCarte.phonePrefix),
        phoneNumber: this.newCarte.phone,
        dialCode: this.newCarte.phonePrefix);
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _carteRepository.loadAddCarteSettings(this.newCarte.type);
    if (apiResponse.status == 200) {
      try {
        this.listAfiliations = json.decode(apiResponse.data)['options'];
      } catch (e) {
        print(e);
      }

      try {
        this.carteTexts =
            carteTextFromJson(json.decode(apiResponse.data)['textes']);
      } catch (e) {
        print(e);
      }

      if (this.newCarte.id == null) {
        DateTime date = new DateTime.now();
        this.newCarte.dateDisplay =
            DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
        this.newCarte.date = date;
        dateController.text = this.newCarte.dateDisplay!;
      }
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  bool showLienDefunt() {
    if (this.newCarte.type == 'death' ||
        this.newCarte.type == 'remercie' ||
        this.newCarte.type == 'invocation') {
      return true;
    }
    return false;
  }

  String getDescription() {
    if (this.newCarte.type == 'death') {
      return "C’est avec une grande tristesse que nous vous annonçons le décès de";
    } else {
      return "Profondément émus par votre soutien et sympathie, nous tenions à vous remercier très chaleureusement de votre présence de votre bienveillance.";
    }
  }

  String getMiddleRamhou() {
    if (this.newCarte.sex == 'm') {
      return "Allah y rhamo";
    } else {
      return "Allah y rhamaha";
    }
  }

  String getBottom() {
    if (this.newCarte.type == 'death') {
      return "Inna lillahi wa inna ilayhi raji'un\nإِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ";
    } else if (this.newCarte.type != 'death') {
      return "Qu'Allah vous accorde Jannat Al Fridaws";
    } else {
      return "";
    }
  }

  String getGeneratedContent() {
    String text = "";
    this.carteTexts.forEach((carteText) {
      String onMyName = carteText.forOther ? "toother" : "myname";
      if (carteText.type == this.newCarte.type &&
          onMyName == this.newCarte.onmyname) {
        if (!carteText.forOther) {
          text = carteText.content;
          text = text.replaceAll(
              '{genre_affiliation}', this.getGenreAffiliation());
          text = text.replaceAll('{affiliation}', this.getAffiliationLabel());
          text = text.replaceAll('{allyramou_genre}', this.getAllahrhamou());
        } else if (this.newCarte.firstname.length > 0 &&
            this.newCarte.lastname.length > 0) {
          String firstname = this.newCarte.firstname;
          firstname =
              firstname.replaceFirst(firstname[0], firstname[0].toUpperCase());
          String lastname = this.newCarte.lastname;
          lastname =
              lastname.replaceFirst(lastname[0], lastname[0].toUpperCase());
          String otherName = "$firstname $lastname";
          text = carteText.content;
          text = text.replaceAll('{other_fullname}', otherName);
          text = text.replaceAll(
              '{genre_affiliation}', this.getGenreAffiliation());
          text = text.replaceAll('{affiliation}', this.getAffiliationLabel());
          text = text.replaceAll('{allyramou_genre}', this.getAllahrhamou());
          if (this.newCarte.type == 'searchdette') {
            String fullPhone =
                "${this.newCarte.phonePrefix} ${this.newCarte.phone}";
            text = text.replaceAll('{other_phone}', fullPhone);
          }
        }
      }
    });
    return text;
  }

  String getAffiliationLabel() {
    String afiilLabel = "";
    this.listAfiliations.forEach((key, value) {
      if (key == this.newCarte.afiliation) {
        afiilLabel = value;
      }
    });
    return afiilLabel;
  }

  String getGenreAffiliation() {
    if ([
      'mother',
      'dot',
      'cousine',
      'tante',
      'grandm',
      'bom',
      'bsis',
      'sister',
      'sis',
      'gt'
    ].contains(this.newCarte.afiliation)) {
      this.newCarte.sex = 'f';
      if (this.newCarte.onmyname == 'toother') {
        return 'sa';
      }
      return 'ma';
    }
    this.newCarte.sex = 'm';
    if (this.newCarte.onmyname == 'toother') {
      return 'son';
    }
    return 'mon';
  }

  String getAllahrhamou() {
    return this.getMiddleRamhou();
  }

  save() async {
    if (!this.formKey.currentState!.validate()) {
      return;
    }
    this.isSaving.value = true;
    bool isUpdate = this.newCarte.id != null;
    ApiResponse apiResponse = await _carteRepository.saveCarte(this.newCarte);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      var carteString = json.decode(apiResponse.data)['carte'];
      Carte carte = Carte.fromJson(carteString);
      this
          ._navigationService
          .replaceWith('carteListView', arguments: {"openCarte": carte});
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving.value = false;
    }
  }

  setAfiliation(key) {
    this.newCarte.afiliation = key;
    this.newCarte.sex = this.getSexForCarte(key);
    //update sex
    this.updatedtext.value++;
    notifyListeners();
  }

  getSexForCarte(affiliation) {
    String sex = 'm';
    List<String> femaleAffiliations = [
      'mother',
      'dot',
      'cousine',
      'tante',
      'grandm',
      'bom',
      'bsis',
      'sister',
      'sis',
      'gt'
    ];
    if (femaleAffiliations.contains(affiliation)) {
      sex = 'f';
    }
    return sex;
  }

  setForMeOrOther(key) {
    this.newCarte.onmyname = key;
    notifyListeners();
  }

  setType(key) {
    this.newCarte.type = key;
    notifyListeners();
  }

  openSearchMosque(context) {
    _navigationService
        .navigateWithTransition(MosqueView(isForSelect: true),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {});
  }

  String carteTypeLabel() {
    if (this.newCarte.type == 'death') {
      return 'Annonce d’un décès';
    } else if (this.newCarte.type == 'invocation') {
      return 'Invocation / Doua';
    } else if (this.newCarte.type == 'remercie') {
      return 'Remerciements';
    } else if (this.newCarte.type == 'pardon') {
      return 'Demande de pardon';
    } else if (this.newCarte.type == 'searchdette') {
      return 'Recherche de dettes et emprunts pour un défunt ';
    }
    return "";
  }

  updateDate(DateTime date) {
    newCarte.dateDisplay =
        DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
    newCarte.date = date;
    dateController.text = newCarte.dateDisplay!;
  }

  setPhoneNumber(PhoneNumber phoneNumber) {
    if (phoneNumber.parseNumber() != this.newCarte.phone) {
      //fix multiple updates
      this.newCarte.phone = phoneNumber.parseNumber();
      this.newCarte.phonePrefix = phoneNumber.dialCode!;
      this.phoneNumber = phoneNumber;
      notifyListeners();
    }
  }
}

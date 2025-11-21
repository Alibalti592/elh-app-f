import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/mosque.dart';
import 'package:elh/repository/MosqueRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/Mosque/DeceMosqueView.dart';
import 'package:elh/ui/views/modules/Mosque/EditMosqueView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueController extends FutureViewModel<dynamic> {
  MosqueRepository _mosqueRepository = locator<MosqueRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  bool isLoading = false;
  ValueNotifier<bool> myMosqueLoading = ValueNotifier<bool>(false);
  List<Mosque> mosques = [];
  List<Mosque> myMosques = [];
  List<Mosque> ownMosques = [];
  TextEditingController cityTextController = TextEditingController();
  Bblocation? searchLocation;
  int distance = 10;
  List<int> distances = <int>[5, 10, 20, 50, 100];
  bool isForSelect = false;
  bool isOwner = false;
  bool hasSearch = false;

  MosqueController(isForSelect) {
    this.isForSelect = isForSelect;
  }

  @override
  Future<dynamic> futureToRun() => loadMyMosques();

  Future loadMyMosques() async {
    this.myMosqueLoading.value = true;
    notifyListeners();
    ApiResponse apiResponse = await _mosqueRepository.loadMyMosques();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.myMosques = mosqueFromJson(json.encode(decodeData['mosques']));
      this.isOwner = decodeData['isOwner'];
      this.ownMosques = mosqueFromJson(json.encode(decodeData['ownMosques']));
      this.myMosqueLoading.value = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  Future loadDatas() async {
    String? locationString;
    if (this.searchLocation != null) {
      this.isLoading = true;
      notifyListeners();
      locationString = json.encode(this.searchLocation!.toJson());
      ApiResponse apiResponse = await _mosqueRepository.loadMosques(
          locationString, this.distance.toString());
      this.hasSearch = true;
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        this.mosques = mosqueFromJson(json.encode(decodeData['mosques']));
        this.isLoading = false;
      } else {
        _errorMessageService.errorOnAPICall();
      }
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    this.loadDatas();
  }

  selectMosque(mosque) {
    this._navigationService.back(result: mosque);
  }

  manualAdd() {
    this._navigationService.back(result: 'manual');
  }

  openSearchLocation(context) {
    _navigationService
        .navigateWithTransition(BBLocationView(),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {
      if (value == "setLocation") {
        this.mosques = [];
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

  setActiveMosque(Mosque mosque, active) {
    mosque.isExpanded = active;
    notifyListeners();
  }

  getAdresseLabel(Bblocation location) {
    return "${location.city} - ${location.region}";
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  markFavorite(Mosque mosque) async {
    mosque.isFavorite = !mosque.isFavorite;
    notifyListeners();
    ApiResponse apiResponse = await _mosqueRepository.markFavorite(mosque);
    if (apiResponse.status == 200) {
      String message = mosque.isFavorite
          ? "Mosquée ajoutée aux favoris"
          : "Mosquée retirée des favoris";
      _errorMessageService.showToaster('success', message);
    } else {
      mosque.isFavorite = !mosque.isFavorite;
      notifyListeners();
      _errorMessageService.errorOnAPICall();
    }
  }

  gotToDeceMosque(Mosque mosque) async {
    _navigationService.navigateToView(DeceMosqueView(mosque));
  }

  editMosque(Mosque mosque) async {
    _navigationService
        .navigateToView(EditMosqueView(mosque: mosque))
        ?.then((value) {
      this.loadDatas();
    });
  }

  gotToMap(Mosque mosque) async {
    final double latitude = mosque.location.lat;
    final double longitude = mosque.location.lng;
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      _errorMessageService
          .errorShoMessage("Désolé impossible d'ouvrir la carte");
    }
  }

  contact() async {
    String contact = "+33759676631";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(iosUrl))) {
        await launchUrl(Uri.parse(iosUrl));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(androidUrl))) {
        await launchUrl(Uri.parse(androidUrl));
      }
    }
  }

  showInfo() {
    _errorMessageService.errorShoMessage(
        title: '',
        "Pour recevoir les notifications des publications des Salât Al-Janaza d'une mosquée, ajoute-la en FAVORIS.");
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stacked/stacked.dart';

class BBLocationController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  LocationStore _locationStore = locator<LocationStore>();
  BaseApiHelper _baseApiHelper = locator<BaseApiHelper>();
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  Timer? debounce;
  Bblocation? selectedLocation;
  List<Bblocation> locations = [];
  List<Bblocation> history = [];
  ValueNotifier<bool> currentLocationLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  bool fullAdress = false;

  BBLocationController(fullAdress) {
    this.fullAdress = fullAdress;
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    // this.isLoading = true;
    // notifyListeners();
    // ApiResponse apiResponse = await _bbbRepository.ffff();
    // if (apiResponse.status == 200) {
    //   var data = json.decode(apiResponse.data);
    //   this.isLoading = false;
    //   notifyListeners();
    // } else {
    //   _errorMessageService.errorOnAPICall();
    // }
  }

  String searchTypeLabel() {
    if (this.fullAdress) {
      return 'Rechercher une addresse';
    } else {
      return 'Rechercher une ville';
    }
  }

  searchAdress() async {
    if (this.debounce?.isActive ?? false) {
      this.debounce?.cancel();
    }
    this.debounce = Timer(const Duration(milliseconds: 200), () async {
      String search = this.searchController.text;
      int minLength = 3;
      if (search.length >= minLength) {
        this.isSearching.value = true;
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'User-Agent':
              'MuslimConnect/1.0 (contact@muslim-connect.fr)', // OBLIGATOIRE
        };
        String encodedSearch = Uri.encodeQueryComponent(search);
        String params =
            "q=$encodedSearch&type=municipality&format=jsonv2&limit=10&addressdetails=1&accept-language=fr&addresstype=city";
        // if(this.fullAdress) {
        //   params = "q=$search&format=jsonv2&limit=10&addressdetails=1";
        String url = "https://nominatim.openstreetmap.org/search?$params";
        var apiResponse = await _baseApiHelper.getExternal(url, requestHeaders);
        List lngsExist = [];
        List displayNamesExist = [];
        if (apiResponse.status == 200) {
          this.locations.clear();
          var results = json.decode(apiResponse.data); //List<dynamic>
          results.forEach((result) {
            if (result["addresstype"] != "political") {
              String? city = result["address"]["village"];
              if (city == null) {
                city = result["address"]["city"];
              }
              if (city == null) {
                city = result["address"]["town"];
              }
              if (city != null) {
                Bblocation location = Bblocation.fromJsonPLaces(result);
                //si pas déjà ajouté évite doublon !!
                if (!lngsInList(lngsExist, location.lat, location.lng) &&
                    !this.displayNameList(
                        displayNamesExist, result["display_name"])) {
                  lngsExist.add({
                    'lat': location.lat,
                    'lng': location.lng,
                  });
                  if (result["display_name"] != null) {
                    displayNamesExist.add(result["display_name"]);
                  }
                  this.locations.add(location);
                }
              }
            }
          });
          this.isSearching.value = false;
          notifyListeners();
        } else {
          this.isSearching.value = false;
          _errorMessageService.errorOnAPICall();
        }
      }
    });
  }

  bool lngsInList(lngsExist, lat, lng) {
    lngsExist.forEach((existing) {
      if (existing['lng'] == lng && existing['lat'] == lat) {
        return true;
      }
    });
    return false;
  }

  bool displayNameList(displayNamesExist, newname) {
    if (newname != null) {
      displayNamesExist.forEach((name) {
        if (newname == name) {
          return true;
        }
      });
    }
    return false;
  }

  selectLocation(Bblocation location, context) {
    _locationStore.setLocation(location);
    //pop
    Navigator.of(context).pop('setLocation');
    this.selectedLocation = location;
    this.locations.clear();
    this.searchController.text = location.label;
    //save history ?
    notifyListeners();
  }

  determinePosition() async {
    LocationPermission permission;
    this.currentLocationLoading.value = true;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      const error = PermissionDeniedException("Location Permission is denied");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        this.currentLocationLoading.value = false;
        _errorMessageService.errorShoMessage(
            "Tu n'autorises pas la localisation, active et autorise ta localisation.");
        return Future.error(error);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const error =
          PermissionDeniedException("Location Permission is denied forever");
      // Permissions are denied forever, handle appropriately.
      this.currentLocationLoading.value = false;
      _errorMessageService.errorShoMessage(
          "Tu n'autorises pas la localisation, utilise la recherche !");
      return Future.error(error);
    }

    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      while (!await Geolocator.isLocationServiceEnabled()) {}
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final currentPos = await Geolocator.getCurrentPosition();
    this.reverseSearchLocation(currentPos.latitude, currentPos.longitude);
  }

  reverseSearchLocation(lat, lng) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'User-Agent':
          'MuslimConnect/1.0 (contact@muslim-connect.fr)', // OBLIGATOIRE
    };
    // print("https://nominatim.openstreetmap.org/reverse?lon=$lng&lat=$lat&format=jsonv2&addressdetails=1");
    String url =
        "https://nominatim.openstreetmap.org/reverse?lon=$lng&lat=$lat&format=jsonv2&addressdetails=1"; //&type=municipality villes only !
    var apiResponse = await _baseApiHelper.getExternal(url, requestHeaders);
    if (apiResponse.status == 200) {
      this.locations.clear();
      var result = json.decode(apiResponse.data); //List<dynamic>
      Bblocation location = Bblocation.fromJsonPLaces(result);
      location.lat = lat;
      location.lng = lng;
      this.locations.add(location);
      this.currentLocationLoading.value = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }
}

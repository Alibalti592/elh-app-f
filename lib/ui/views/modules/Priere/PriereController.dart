import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/Praytime.dart';
import 'package:elh/repository/PriereRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/dateService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:elh/ui/views/modules/Qiblah/QiblahView.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PriereController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  PriereRepository _priereRepository = locator<PriereRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  LocationStore _locationStore = locator<LocationStore>();
  DateService _dateService = locator<DateService>();
  bool isLoading = true;
  bool needDefineLocation = false;
  DateTime? date;
  Praytime? praytime;
  Bblocation? searchLocation;
  ValueNotifier<String> nextPrayHour = ValueNotifier<String>("");
  String nextPrayName = '';
  bool isRealoadingPrays = false;

  PriereController() {
    Timer.periodic(Duration(seconds: 1), (Timer t) => setNextPrayHour());
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas({locationString}) async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _priereRepository.loadPrieres(date, locationString);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      if (data['praytime'] == null) {
        this.needDefineLocation = true;
      } else {
        this.praytime = praytimeFromJson(data['praytime']);
        this.needDefineLocation = false;
      }
      this.setNextPrayHour();
      this.isLoading = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  setLocation() {
    _navigationService
        .navigateWithTransition(BBLocationView(),
            transitionStyle: Transition.downToUp,
            duration: Duration(milliseconds: 300))
        ?.then((value) {
      if (value == "setLocation") {
        this.searchLocation = _locationStore.selectedLocation;
        if (this.searchLocation != null) {
          String locationString = json.encode(this.searchLocation!.toJson());
          this.loadDatas(locationString: locationString);
        }
      }
    });
    //CALLBACK !!
  }

  savePrayKey(Priere priere) async {
    priere.isNotified = !priere.isNotified;
    notifyListeners();
    ApiResponse apiResponse =
        await _priereRepository.savePriereNotification(priere.key);
    if (apiResponse.status == 200) {
    } else {
      priere.isNotified = !priere.isNotified;
      notifyListeners();
      _errorMessageService.errorOnAPICall();
    }
  }

  setNextPrayHour() {
    if (this.praytime == null) {
      this.nextPrayHour.value = '';
      return;
    }
    //get next pray
    int currentTimestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    bool issetted = false;
    this.praytime!.prieres.forEach((priere) {
      int timestonow = priere.timestamp - currentTimestamp;
      if (timestonow > 0 && !issetted) {
        Duration duration = Duration(seconds: timestonow);
        this.nextPrayHour.value = _dateService.hhmmss(duration);
        this.nextPrayName = priere.label;
        issetted = true;
        this.isRealoadingPrays = false;
      }
    });
    if (!issetted && !this.isRealoadingPrays) {
      //si on a depassé last pray, reload prays of tomorrow
      this.isRealoadingPrays = true;
      this.loadDatas();
    }
  }

  String adjustTimeForParis(String timeStr) {
    // Step 1: Parse the input Paris time string (HH:mm)
    List<String> parts = timeStr.split(':');
    int parisHour = int.parse(parts[0]);
    int parisMinute = int.parse(parts[1]);

    // Step 2: Get Paris timezone offset (CET = UTC+1, CEST = UTC+2)
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime parisTime = nowUtc.add(Duration(hours: 1)); // Default CET (UTC+1)

    // Adjust for CEST (summer time: last Sunday in March → last Sunday in October)
    if (DateTime.now().isAfter(DateTime.utc(nowUtc.year, 3, 31)) &&
        DateTime.now().isBefore(DateTime.utc(nowUtc.year, 10, 31))) {
      parisTime = nowUtc.add(Duration(hours: 2)); // CEST (UTC+2)
    }
    Duration parisOffset = parisTime.difference(nowUtc);

    // Step 3: Get local timezone offset
    //on défini la locale sur là ou on est et pas sur la ville sélecitionnée, devrait etre ok
    Duration localOffset = DateTime.now().timeZoneOffset;

    // Step 4: Calculate the difference (local offset - Paris offset)
    int hourDifference = (localOffset - parisOffset).inHours;

    int adjustedHour = (parisHour + hourDifference) % 24;
    if (adjustedHour < 0) adjustedHour += 24;

    // Step 6: Format and return new local time
    final adjustedTime = DateFormat('HH:mm').format(
      DateTime(2023, 1, 1, adjustedHour, parisMinute),
    );

    return adjustedTime;
  }

  void goTo(String viewName) {
    Widget view;
    view = QiblahView();
  }

  // Future<Duration> getLocalOffset() async {
  //   if(!this.lo)
  //   tz.initializeTimeZones(); // Load timezone data
  //   List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
  //   String? timezoneName = placemarks.isNotEmpty ? placemarks[0].isoCountryCode : "UTC";
  //   final location = tz.getLocation(timezoneName ?? "UTC");
  //   final localTime = tz.TZDateTime.now(location);
  //   return localTime.timeZoneOffset;
  // }
}

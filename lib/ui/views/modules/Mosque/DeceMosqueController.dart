import 'dart:async';
import 'dart:convert';
import 'package:elh/models/mosque.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/repository/MosqueRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/Salat/SharetoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DeceMosqueController extends FutureViewModel<dynamic> {
  MosqueRepository _mosqueRepository = locator<MosqueRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  ScrollController scrollController = new ScrollController();
  bool isLoading = false;
  ValueNotifier<bool> myMosqueLoading = ValueNotifier<bool>(false);
  List<Salat> salats = [];
  Mosque mosque;

  DeceMosqueController(this.mosque);

  @override
  Future<dynamic> futureToRun() => loadDeceMosques();

  Future loadDeceMosques() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _mosqueRepository.loadMosquesDeces(this.mosque);
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      try {
        this.salats = salatFromJson(decodeData['salats']);
      } catch (e) {}
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    this.loadDeceMosques();
  }

  shareSalat(Salat salat) {
    _navigationService.navigateToView(SharetoView(salat));
  }
}

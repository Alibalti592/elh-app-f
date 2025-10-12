import 'dart:async';
import 'dart:convert';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class JeunController extends FutureViewModel<dynamic> {
  TestamentRepository _testamentRepository = locator<TestamentRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  String title = "Jours de jeûn à rattraper";
  bool isLoading = true;
  bool isAlreadyRegistred = false;
  int selectedYear = 2025;
  List<int> yearList = [];
  UserInfos? userInfos;
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();
  String jeunText = "";
  int jeunNbDays = 0;
  int jeunNbDaysR = 0;
  int iniYearIndex = 2;

  JeunController() {
    int currentYear = DateTime.now().year;
    this.selectedYear = currentYear;
    this.yearList = List.generate(10, (index) => currentYear - 2 + index);
    this.iniYearIndex = this.yearList.indexOf(selectedYear);
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.getJeun();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      try {
        this.jeunText = decodeData['jeunText'].toString();
        this.jeunNbDays = decodeData['jeunNbDays'];
        this.selectedYear = decodeData['selectedYear'];
        this.iniYearIndex = this.yearList.indexOf(this.selectedYear);
        this.jeunNbDaysR = decodeData['jeunNbDaysR'];
      } catch(e) {
      }
    } else {
      _errorMessageService.errorOnAPICall();
    }
    this.isLoading = false;
    notifyListeners();
  }

  saveJeun() async {
    if(!this.formKey.currentState!.validate()) {
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse = await _testamentRepository.saveJeun(this.jeunText, this.jeunNbDays, this.jeunNbDaysR, this.selectedYear);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      _errorMessageService.showToaster('success', "Jours de jeûn à rattraper mis à jour");
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving.value = false;
    }
  }

  String getLabelText() {
    int currentYear = DateTime.now().year;
    return "Nombre de jours de jeun manqués ou à rattraper Ramadan ${currentYear}";
  }

}
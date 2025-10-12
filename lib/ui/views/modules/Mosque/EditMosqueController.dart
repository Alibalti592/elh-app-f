import 'dart:async';
import 'package:elh/models/mosque.dart';
import 'package:elh/repository/MosqueRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class EditMosqueController extends FutureViewModel<dynamic> {
  MosqueRepository _mosqueRepository = locator<MosqueRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  String title = "Ma mosquée";
  bool isLoading = true;
  bool isAlreadyRegistred = false;
  Mosque? mosque;
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();

  EditMosqueController(mosque) {
    if(mosque != null) {
      this.mosque = mosque;
    }
    this.isLoading = false;
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {

  }

  saveMosque() async {
    if(!this.formKey.currentState!.validate()) {
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse = await _mosqueRepository.saveMosque(this.mosque!);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      this._navigationService.popRepeated(1);
    } else {
      this.isSaving.value = false;
      _errorMessageService.errorOnAPICall();
    }
  }

  setDescription(description) {
    print(description);
    this.mosque!.description = description;
  }
}
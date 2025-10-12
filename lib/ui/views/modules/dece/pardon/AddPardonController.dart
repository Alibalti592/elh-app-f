import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/pardon.dart';
import 'package:elh/repository/PardonRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddPardonController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  PardonRepository _pardonRepository = locator<PardonRepository>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  bool isLoading = false;
  Pardon newPardon = new Pardon( firstname: '', lastname: '', content: '');
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  AddPardonController(pardon) {
    if(pardon != null) {
      this.newPardon = pardon;
    }
  }

  @override
  Future<dynamic> futureToRun() => ini();

  ini() {

  }

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _pardonRepository.loadAddPardonSettings();
    if (apiResponse.status == 200) {
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
    DialogResponse? response =
        await _dialogService.showDialog(title: 'Envoyer', description: "Valider et envoyer la demande de pardon à mes contacts");
    if(response != null && response.confirmed) {
      this.isSaving.value = true;
      ApiResponse apiResponse = await _pardonRepository.savePardon(this.newPardon);
      if (apiResponse.status == 200) {
        this.isSaving.value = false;
        this._navigationService.back(result: 'updateListe');
      } else {
        _errorMessageService.errorOnAPICall();
        this.isSaving.value = false;
      }
    }

  }

}
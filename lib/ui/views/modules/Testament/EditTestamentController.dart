import 'dart:async';
import 'package:elh/models/Testament.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class EditTestamentController extends FutureViewModel<dynamic> {
  TestamentRepository _testamentRepository = locator<TestamentRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserInfoReactiveService _userInfoReactiveService = locator<UserInfoReactiveService>();
  String title = "Rédiger mon testament";
  bool isLoading = false;
  bool isAlreadyRegistred = false;
  late Testament testament;
  UserInfos? userInfos;
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();

  EditTestamentController(testament) {
    this.testament = testament;
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.userInfos = await _userInfoReactiveService.getUserInfos(cache: true);
  }

  saveTestament() async {
    if(!this.formKey.currentState!.validate()) {
      return;
    }
    this.isSaving.value = true;
    ApiResponse apiResponse = await _testamentRepository.saveTestament(this.testament);
    if (apiResponse.status == 200) {
      this.isSaving.value = false;
      this._navigationService.popRepeated(1);
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving.value = false;
    }
  }

}
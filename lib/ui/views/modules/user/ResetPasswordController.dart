import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/modules/user/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ResetPasswordController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  final UserRepository userRepository = locator<UserRepository>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  bool showResetUI = false;
  bool isLoading = false;
  bool obscureText = true;


  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {

  }


  goBack() {
    _navigationService.back();
  }


 resetPassword(String username) async {
    this.isLoading = true;
    notifyListeners();
    try {
      ApiResponse apiResponse = await userRepository.resetPassword(username);
      if(apiResponse.status == 200) {
        this.showResetUI = true;
      } else {
        _errorMessageService.errorShoMessage(apiResponse.data);
      }
      this.isLoading = false;
      notifyListeners();
    } catch(e) {
      this.isLoading = false;
      notifyListeners();
    }
  }

  confirmResetPassword() async {
    this.isLoading = true;
    notifyListeners();
    var password = this.newpasswordController.text;
    var code = this.codeController.text.trim();
    var email = this.usernameController.text.trim();
    try {
      ApiResponse apiResponse = await userRepository.confirmResetPassword(password, code, email);
      if(apiResponse.status == 200) {
        _navigationService.clearStackAndShowView(Login(initialPage: 1));
      } else {
        _errorMessageService.errorShoMessage(apiResponse.data);
      }
      this.isLoading = false;
      notifyListeners();
    } catch(e) {
      this.isLoading = false;
      notifyListeners();
    }
  }


  toogleobscureText() {
    if(obscureText) {
      obscureText = false;
    } else {
      obscureText = true;
    }
    notifyListeners();
  }
}
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';


class HandleApiResponseError {
  final ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  bool hasError = false; //permet d'éviter d'aficher 40 fois la popup async ...

  onApiResponseError(ApiResponse apiResponseWithError) async {
      var message;
      try {
        //check if message !
        var data = json.decode(apiResponseWithError.data);
        if(data.containsKey('message')) {
          message = data['message'];
        }
      } on FormatException {

      }
      _errorMessageService.errorOnAPICall(message: message);
  }
}
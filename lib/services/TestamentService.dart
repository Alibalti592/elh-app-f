import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';

class TestamentService {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  TestamentRepository _testamentRepository = locator<TestamentRepository>();

  Future loadDettes(Testament testament) async {
    List<Obligation> jeds = [];
    List<Obligation> onms = [];
    List<Obligation> amanas = [];
    ApiResponse apiResponse = await _testamentRepository.loadTestamentDettes(testament);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      try {
        jeds = obligationFromJson(data['jeds']);
      } catch(e) {}
      try {
        onms = obligationFromJson(data['onms']);
      } catch(e) {}
      try {
        amanas = obligationFromJson(data['amanas']);
      } catch(e) {}
    } else {
      _errorMessageService.errorOnAPICall();
    }
    return {
      'jeds': jeds,
      'onms': onms,
      'amanas': amanas
    };
  }

}
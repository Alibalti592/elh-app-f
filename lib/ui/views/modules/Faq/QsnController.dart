import 'dart:async';
import 'dart:convert';
import 'package:elh/repository/FaqRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:stacked/stacked.dart';

class QsnController extends FutureViewModel<dynamic> {
  FaqRepository _faqRepository = locator<FaqRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  bool isLoading = true;
  String content = "";


  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _faqRepository.loadQsn();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.content = decodeData['content'];
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

}
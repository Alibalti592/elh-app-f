import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/TestamentService.dart';
import 'package:elh/ui/views/modules/Testament/PreviewTestamentView.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/models/Obligation.dart';

class ListSharedTestamentController extends FutureViewModel<dynamic> {
  NavigationService _navigationService = locator<NavigationService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  TestamentRepository _testamentRepository = locator<TestamentRepository>();
  TestamentService _testamentService = locator<TestamentService>();
  DetteRepository _detteRepository = locator<DetteRepository>();
  bool isLoading = false;
  List<Testament> othersTestaments = [];
  List<Obligation> obligations = [];

  @override
  Future<dynamic> futureToRun() => loadOtherTestament();

  Future loadOtherTestament() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.loadOthersTestament();
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      try {
        this.othersTestaments = [];
        data['othersTestaments'].forEach((testament) {
          this.othersTestaments.add(testamentFromJson(testament));
        });
      } catch (e) {}
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
  }

  Future loadDettes() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _detteRepository.loadDettesNotRefund();
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      try {
        this.obligations = obligationFromJson(data['obligations']);
      } catch (e) {}
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
  }

  Future<void> refreshDatas() async {
    this.loadOtherTestament();
  }

  gotToOtherTestament(testament) async {
    this.isLoading = true;
    notifyListeners();
    //load obligations and put in View !!
    var dettes = await _testamentService.loadDettes(testament);
    _navigationService
        .navigateWithTransition(PreviewTestamentView(
            testament, dettes['jeds'], dettes['onms'], dettes['amanas']))
        ?.then((value) {
      this.isLoading = false;
      notifyListeners();
    });
  }
}

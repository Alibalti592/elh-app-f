import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:stacked/stacked.dart';
import 'package:elh/models/Obligation.dart';
import 'package:url_launcher/url_launcher.dart';


class PreviewTestamentController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  TestamentRepository _testamentRepository = locator<TestamentRepository>();
  bool isLoading = false;
  List<Obligation> jeds = [];
  List<Obligation> onms = [];
  Testament testament;
  bool pdfLoading = false;
  String joursJeun = "Aucun jour à rattraper";

  PreviewTestamentController(this.testament);
  @override
  Future<dynamic> futureToRun() => loadDatas();

  //load JDM | ODM
  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.loadJeuntext(this.testament);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      this.joursJeun = data['jeunText'];
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
  }


  Future<void> refreshDatas() async {
    this.isLoading = true;
    notifyListeners();
    this.loadDatas();
  }

  exportAsPdf() async {
    this.pdfLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.getPdfLink(
        this.testament!);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      String s3PdfUrl = data['url'];
      if (await canLaunchUrl(Uri.parse(s3PdfUrl))) {
        await launchUrl(
            Uri.parse(s3PdfUrl), mode: LaunchMode.externalApplication);
        this.pdfLoading = false;
        notifyListeners();
      } else {
        throw 'Could not open PDF';
      }
    }
  }
}
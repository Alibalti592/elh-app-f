import 'dart:async';
import 'dart:convert';
import 'package:elh/models/Faq.dart';
import 'package:elh/repository/FaqRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqController extends FutureViewModel<dynamic> {
  FaqRepository _faqRepository = locator<FaqRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  bool isLoading = true;
  List<Faq> faqs = [];


  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _faqRepository.loadFaqs();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.faqs = faqsFromJson(decodeData['faqs']);
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  setActiveFaq(Faq faq, active) {
    faq.isExpanded = active;
    notifyListeners();
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
    return false;
  }

}
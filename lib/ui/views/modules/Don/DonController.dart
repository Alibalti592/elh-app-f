import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/models/don.dart';
import 'package:elh/repository/DonRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class DonController extends FutureViewModel<dynamic> {
  DonRepository _donRepository = locator<DonRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  late SharedPreferences prefs;
  bool isLoading = true;
  String textIntro = '';
  List<Don> dons = [];
  List<int> doneIds = [];

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _donRepository.loadDons();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.dons = donsFromJson(decodeData['dons']);
      this.textIntro = decodeData['intro'];
      this.prefs = await SharedPreferences.getInstance();
      try {
        List<String> mList = (prefs.getStringList('doneIds') ?? []);
        this.doneIds = mList.map((i)=> int.parse(i)).toList();
      } catch(e) {}
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  gotToLink(don) async  {
    if(don.link != null) {
      if (await canLaunchUrl(Uri.parse(don.link))) {
        await launchUrl(Uri.parse(don.link));
      }
    }
  }

  Future<void> refreshData() async {
    this.loadDatas();
  }

  contact() async {
    String contact = "+33759676631";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(iosUrl))) {
        await launchUrl(Uri.parse(iosUrl));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(androidUrl))) {
        await launchUrl(Uri.parse(androidUrl));
      }
    }
  }

}
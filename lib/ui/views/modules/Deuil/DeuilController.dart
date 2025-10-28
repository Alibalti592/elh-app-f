import 'dart:async';
import 'dart:convert';
import 'package:elh/models/deuildate.dart';
import 'package:elh/repository/DeuilRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeuilController extends FutureViewModel<dynamic> {
  DeuilRepository _deuilRepository = locator<DeuilRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  TextEditingController dateController = TextEditingController();
  List<DeuilDate> deuilDates = [];
  bool isLoadingdeuilsdates = false;
  bool isLoading = false;
  bool isSsaving = false;
  DateTime? startDate;
  DateTime maxTime = DateTime.now();
  String content = "";
  String endDate = "";
  String ref = "na";
  String? selectPeriod;

  int step = 1;
  String type = 'nc';

  DeuilController() {
    maxTime = maxTime.add(Duration(days: 30));
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadDeuilDates();

  getBarLAbel() {
    if (this.type == 'nc') {
      return 'Calcul de la période de deuil';
    } else if (this.type == "family") {
      return "Pour la famille";
    } else if (this.type == "epouse") {
      return "Pour l'épouse";
    } else if (this.type == "enceinte") {
      return "Pour l'épouse enceinte";
    }
  }

  selectType(type) {
    this.type = type;
    this.step = 2;
    this.content = "";
    this.endDate = "";
    this.ref = "na";
    this.startDate = null;
    this.dateController.text = "";
    notifyListeners();
  }

  goBack() {
    if (this.step == 2) {
      this.step = 1;
      notifyListeners();
    } else {
      _navigationService.back();
    }
  }

  getLabelDate() {
    if (this.type == 'enceinte') {
      return "Saisir la date de l'accouchement";
    }
    return "Saisir la date du décès";
  }

  Future loadDatas() async {
    if (this.startDate != null) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse = await _deuilRepository.loadDeuil(
          this.startDate!.toIso8601String(), type);
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        this.content = decodeData['content'];
        this.endDate = decodeData['endDate'];
        this.ref = decodeData['ref'].toString();
        this.isLoading = false;
      } else {
        _errorMessageService.errorOnAPICall();
      }
      notifyListeners();
    }
  }

  Future loadDeuilDates() async {
    ApiResponse apiResponse = await _deuilRepository.loadDeuilDates();
    if (apiResponse.status == 200) {
      try {
        this.deuilDates =
            deuildatesFromJson(json.decode(apiResponse.data)['deuilDates']);
      } catch (e) {
        print(e);
      }
      this.isLoadingdeuilsdates = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  updateDate(DateTime date) {
    this.startDate = date;
    dateController.text = DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
    this.loadDatas();
  }

  savePeriode(dateString) async {
    this.isSsaving = true;
    notifyListeners();
    await _deuilRepository.saveDeuilDate(dateString.toString(), this.ref);
    this.isSsaving = false;
    this.step = 1;
    this.startDate = null;
    this.endDate = "";
    this.content = "";
    this.ref = "na";
    notifyListeners();
    this.loadDeuilDates();
  }

  deleteDeuildate(deuilDate) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: 'Période de deuil',
        description:
            "Tu es certain de vouloir supprimer cette période de deuil ?",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Confirmer');
    if (confirm?.confirmed == true) {
      this.isLoadingdeuilsdates = true;
      notifyListeners();
      await _deuilRepository.deleteDeuilDate(deuilDate.id.toString());
      this.loadDeuilDates();
    }
  }
}

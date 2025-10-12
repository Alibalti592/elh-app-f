import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/PompeDemand.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/repository/DeceRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/modules/dece/AddDeceView.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DeceDetailsController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  DeceRepository _deceRepository = locator<DeceRepository>();
  DialogService _dialogService = locator<DialogService>();
  Dece dece;
  bool isnotifying = false;
  bool isLoading = false;
  List<PompeDemand> demands = [];
  DeceDetailsController(this.dece);

  @override
  Future<dynamic> futureToRun() => loadPfs();

  Future loadPfs() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _deceRepository.loadPfs(this.dece.id.toString());
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      try {
        this.demands = pompeDemandsFromJson(decodeData['demands']);
      } catch (e) {
      }
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }


  notifyPF() async {
    this.isnotifying = true;
    notifyListeners();
    ApiResponse apiResponse = await _deceRepository.notifyPFs(this.dece.id.toString());
    if (apiResponse.status == 200) {
      this.dece.notifPf = true;
      this.loadPfs();
      this.isnotifying = false;
      notifyListeners();
    } else {
      _errorMessageService.errorOnAPICall();
      this.isnotifying = false;
      notifyListeners();
    }
  }


  editDece(dece) {
    _navigationService.navigateWithTransition(AddDeceView(dece: dece), transitionStyle: Transition.rightToLeft, duration:Duration(milliseconds: 300))?.then((value) {
      if(value == "updateListe") {
        this.loadPfs();
      }
    });
  }

  deleteDece(dece) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: "Supprimer ?", description: "Supprimer  ce décès ?", cancelTitle: 'Annuler', confirmationTitle: 'Supprimer');

    if(confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse = await _deceRepository.deleteDece(dece);
      if(apiResponse.status == 200) {
        this._navigationService.back(result: 'updateListe');
      } else {
        _errorMessageService.errorDefault();
      }
      this.isLoading = false;
      notifyListeners();
    }

  }
  
}
import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Dette/AddObligationView.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCard.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactView.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/models/Obligation.dart';

class DetteController extends FutureViewModel<dynamic> {
  NavigationService _navigationService = locator<NavigationService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DetteRepository _detteRepository = locator<DetteRepository>();
  DialogService _dialogService = locator<DialogService>();
  bool isLoading = false;
  List<Obligation> obligations = [];
  List<Obligation> obligationsShared = [];
  num totalAmount = 0;
  int tabIndex = 0;
  late String detteType;
  String filter = 'processing';

  DetteController(this.detteType, tab) {
    if (tab == 'refund') {
      this.tabIndex = 1;
      this.filter = 'refund';
    }
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _detteRepository.loadDette(this.detteType, filter);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      try {
        print("data = $data");
        this.obligations = obligationFromJson(data['obligations']);
      } catch (e) {}
      try {
        this.obligationsShared = obligationFromJson(data['obligationsShared']);
      } catch (e) {}
      if (filter == 'processing' || filter == 'refund') {
        this.totalAmount = data['totalAmount'];
      }
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
  }

  setTabEnLoadDatas(tab) {
    if (tab == 0) {
      this.filter = 'processing';
    } else {
      this.filter = 'refund';
    }
    this.loadDatas();
  }

  String getTitle() {
    if (this.detteType == 'jed') {
      return "Mes dettes";
    } else if (this.detteType == 'onm') {
      return "Mes prêts";
    }
    return "Mes Amanas";
  }

  String getTab1Title() {
    return "En cours";
  }

  String getTab2Title() {
    if (this.detteType == 'jed') {
      return "Remboursés";
    } else if (this.detteType == 'onm') {
      return "Remboursés";
    }
    return "Toutes mes amanas";
  }

  Future<void> refreshDatas() async {
    this.isLoading = true;
    notifyListeners();
    this.loadDatas();
  }

  addObligation(type) {
    _navigationService
        .navigateWithTransition(AddObligationView(type, obligation: null))
        ?.then((value) {
      this.loadDatas();
    });
  }

  editObligation(Obligation obligation) {
    _navigationService
        .navigateWithTransition(
            AddObligationView(obligation.type, obligation: obligation))
        ?.then((value) {
      this.loadDatas();
    });
  }

  deleteObligation(Obligation obligation) async {
    String title = "Supprimer la dette ?";
    String descr =
        "Confirmer la supression de cette dette pour vous et pour la personne associée à cette dette";
    if (obligation.type == 'onm') {
      title = "Supprimer le prêt ?";
      descr =
          "Confirmer la supression de ce prêt  pour vous et pour la personne associée à ce prêt";
    } else if (obligation.type == 'amana') {
      title = "Supprimer la amana ?";
      descr =
          "Confirmer la supression de cette amana  pour vous et pour la personne associée à cette amana";
    }
    var confirm = await _dialogService.showConfirmationDialog(
        title: title,
        description: descr,
        cancelTitle: 'Annuler',
        confirmationTitle: 'Supprimer');
    if (confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse =
          await _detteRepository.deleteDette(obligation.id);
      if (apiResponse.status == 200) {
        this.loadDatas();
      } else {
        _errorMessageService.errorDefault();
        this.isLoading = false;
        notifyListeners();
      }
    }
  }

  isEcheance(Obligation obligation) {
    DateTime today = DateTime.now();
    DateTime onlyToday = DateTime(today.year, today.month, today.day);
    if (obligation.dateStart != null) {
      DateTime obligationDate = DateTime(obligation.dateStart!.year,
          obligation.dateStart!.month, obligation.dateStart!.day);
      if (!obligationDate.isAfter(onlyToday)) {
        return true;
      }
    }
    return false;
  }

  refundObligation(Obligation obligation) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: "Remboursement de la dette?",
        description: "Confirmer le remboursement de cette dette",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Valider');
    if (confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse =
          await _detteRepository.refundDette(obligation.id, false);
      if (apiResponse.status == 200) {
        this.loadDatas();
      } else {
        _errorMessageService.errorDefault();
        this.isLoading = false;
        notifyListeners();
      }
    }
  }

  cancelRefundObligation(Obligation obligation) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: "Annuler le remboursement de la dette?",
        description: "Confirmer l'annulation du remboursement de cette dette",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Valider');
    if (confirm?.confirmed == true) {
      this.isLoading = true;
      notifyListeners();
      ApiResponse apiResponse =
          await _detteRepository.refundDette(obligation.id, true);
      if (apiResponse.status == 200) {
        this.loadDatas();
      } else {
        _errorMessageService.errorDefault();
        this.isLoading = false;
        notifyListeners();
      }
    }
  }

  openObligationCard(context, obligation, directShare) {
    Navigator.of(context).push(
      HeroDialogRoute(
        builder: (context) => Center(
          child:
              ObligationCard(obligation: obligation, directShare: directShare),
        ),
      ),
    );
  }

  addRelatedTo(obligation) async {
    var confirm = await _dialogService.showConfirmationDialog(
        title: "",
        description:
            "Les partages d'un PRÊT/DETTE/AMANA avec un de vos contact MC, seront automatiquement visibles sur son compte Muslim Connect",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Partager');
    if (confirm?.confirmed == true) {
      _navigationService
          .navigateWithTransition(SelectContactView(),
              transitionStyle: Transition.downToUp,
              duration: Duration(milliseconds: 300))
          ?.then((value) async {
        if (value != null) {
          Relation relation = value;
          //relation.user.id
          this.isLoading = true;
          notifyListeners();
          ApiResponse apiResponse = await _detteRepository.setRelatedTo(
              obligation.id, relation.user.id);
          if (apiResponse.status == 200) {
            this.loadDatas();
          } else {
            _errorMessageService.errorDefault();
            this.isLoading = false;
            notifyListeners();
          }
        }
      });
    }
  }

  // editDette() {
  //   _navigationService.navigateWithTransition(EditDetteView(this.testament))?.then((value) {
  //     this.loadDatas();
  //   });
  // }
  //
  // shareDette() {
  //   _navigationService.navigateWithTransition(ShareToView())?.then((value) {
  //     this.loadDatas();
  //   });
  // }
  //
  // gotToOtherDette(testament) {
  //   _navigationService.navigateWithTransition(PreviewDetteView(testament))?.then((value) {
  //   });
  // }
}

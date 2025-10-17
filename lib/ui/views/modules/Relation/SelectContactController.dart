// import 'dart:async';
// import 'dart:convert';
// import 'package:elh/models/Relation.dart';
// import 'package:elh/repository/RelationRepository.dart';
// import 'package:elh/services/BaseApi/ApiResponse.dart';
// import 'package:elh/services/ErrorMessageService.dart';
// import 'package:elh/locator.dart';
// import 'package:elh/ui/views/modules/Relation/SearchRelationView.dart';
// import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';

// class SelectContactController extends FutureViewModel<dynamic> {
//   RelationRepository _relationRepository = locator<RelationRepository>();
//   ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
//   NavigationService _navigationService = locator<NavigationService>();
//   DialogService _dialogService = locator<DialogService>();
//   bool isLoading = true;
//   List<Relation> relations = [];
//   int? nbRelations;

//   @override
//   Future<dynamic> futureToRun() => loadDatas();

//   Future loadDatas() async {
//     ApiResponse apiResponse = await _relationRepository.loadActiveRelations();
//     if (apiResponse.status == 200) {
//       var decodeData = json.decode(apiResponse.data);
//       this.relations = relationFromJson(decodeData['relations']);
//       this.nbRelations = decodeData['nbRelations'];
//       this.isLoading = false;
//     } else {
//       _errorMessageService.errorOnAPICall();
//     }
//     notifyListeners();
//   }

//   Future<void> refreshDatas() async {
//     this.isLoading = true;
//     notifyListeners();
//     this.loadDatas();
//   }

//   String nbRelationsLabel() {
//     if (this.nbRelations == null) {
//       return "";
//     } else {
//       return "(${this.nbRelations.toString()})";
//     }
//   }

//   selectRelation(Relation relation) async {
//     this._navigationService.back(result: relation);
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:elh/models/Relation.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactView.dart';
import 'package:elh/ui/views/modules/Relation/AjouterEmprunteur.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SelectContactController extends FutureViewModel<dynamic> {
  final RelationRepository _relationRepository = locator<RelationRepository>();
  final ErrorMessageService _errorMessageService =
      locator<ErrorMessageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  bool isLoading = true;
  bool isPersonFormVisible = false;
  bool canOpenPhoneContacts = true; // Flag to show phone contact option

  List<Relation> relations = [];
  int? nbRelations;

  // Example obligation object
  Obligation obligation = Obligation();

  // Text controllers for form
  TextEditingController firstnameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController phoneTextController = TextEditingController();

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    ApiResponse apiResponse = await _relationRepository.loadActiveRelations();
    if (apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.relations = relationFromJson(decodeData['relations']);
      this.nbRelations = decodeData['nbRelations'];
      this.isLoading = false;
    } else {
      _errorMessageService.errorOnAPICall();
    }
    notifyListeners();
  }

  Future<void> refreshDatas() async {
    this.isLoading = true;
    notifyListeners();
    await this.loadDatas();
  }

  String nbRelationsLabel() {
    if (this.nbRelations == null) return "";
    return "(${this.nbRelations.toString()})";
  }

  // Select a relation and pass it back
  void selectRelation(Relation relation) {
    _navigationService.back(result: relation);
  }

  // Toggle person form visibility
  // void tglePersonFormDetails() {
  //   isPersonFormVisible = !isPersonFormVisible;
  //   notifyListeners();
  // }

  void tglePersonFormDetails() {
    _navigationService.back(
        result: 'showForm'); // no need to handle the form here
  }

  getPersonneLabel() {
    if (this.obligation.type == 'jed') {
      return "Ajouter un emprunteur";
    } else if (this.obligation.type == 'onm') {
      return "Ajouter un prêteur";
    }
    return "Ajouter une personne";
  }

  // Open phone contacts to select a contact
  // Future<void> listPhoneContact() async {
  //   _navigationService
  //       .navigateWithTransition(ListPhoneContactView(),
  //           transitionStyle: Transition.downToUp,
  //           duration: Duration(milliseconds: 300))
  //       ?.then((contact) {
  //     if (contact != null && contact is Contact) {
  //       obligation.firstname = contact.name.first;
  //       obligation.lastname = contact.name.last;
  //       firstnameTextController.text = obligation.firstname;
  //       lastNameTextController.text = obligation.lastname;

  //       if (contact.phones != null && contact.phones.isNotEmpty) {
  //         obligation.tel = contact.phones.first.number;
  //         phoneTextController.text = obligation.tel;
  //       }

  //       notifyListeners();
  //     }
  //   });
  // }
  Future<void> goToSelectContact({bool phoneContacts = false}) async {
    // Navigate to the appropriate contact selector
    final result = await _navigationService.navigateWithTransition(
      phoneContacts ? ListPhoneContactView() : SelectContactView(),
      transitionStyle: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    // Handle the result
    if (result != null) {
      if (result == 'showForm') {
        // User chose to create a contact manually
        isPersonFormVisible = true;
        notifyListeners();
      } else if (result is UserInfos) {
        // User selected a contact (phone or community)
        obligation.firstname = result.firstname ?? '';
        obligation.lastname = result.lastname ?? '';
        obligation.tel = result.phone ?? '';
        obligation.adress = result.city ?? '';
        obligation.relatedUserId = result.id ?? null;
        print("result : ${result}");
        // Update form controllers
        firstnameTextController.text = obligation.firstname;
        lastNameTextController.text = obligation.lastname;
        phoneTextController.text = obligation.tel;

        // Show the form
        isPersonFormVisible = true;
        notifyListeners();

        print(
            "Selected contact: ${obligation.firstname} ${obligation.lastname}");
      }
    }
  }

  listPhoneContact() {
    _navigationService
        .navigateWithTransition(
      ListPhoneContactView(),
      transitionStyle: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    )
        ?.then((contact) {
      if (contact != null && contact is Contact) {
        // Prefill first name
        this.obligation.firstname = contact.name.first;
        this.firstnameTextController.text = this.obligation.firstname;

        // Prefill last name
        this.obligation.lastname = contact.name.last;
        this.lastNameTextController.text = this.obligation.lastname;

        // Prefill phone
        if (contact.phones.isNotEmpty) {
          this.obligation.tel = contact.phones.first.number;
          this.phoneTextController.text = this.obligation.tel;
        }

        // Phone contacts have no related user ID
        this.obligation.relatedUserId = null;

        print("Phone contact selected: ${contact.name.first}");
        print("Controller text: ${firstnameTextController.text}");

        // Toggle form to show user info
        tglePersonFormDetails();
        notifyListeners();
      }
    });
  }

  Future<void> selectFromPhoneContacts() async {
    final contact = await _navigationService.navigateWithTransition(
      ListPhoneContactView(),
      transitionStyle: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    if (contact != null) {
      // Convert phone contact to a UserInfos-like object
      final user = UserInfos(
        firstname: contact.name.first,
        lastname: contact.name.last,
        phone: contact.phones != null && contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '',
        photo: '',
        fullname: '',
        phonePrefix: '',
        city: '',
      );

      // Return as if it were selected from community
      _navigationService.back(result: user);
    }
  }
}

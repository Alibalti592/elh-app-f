import 'dart:async';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactView.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddObligationController extends FutureViewModel<dynamic> {
  DetteRepository _detteRepository = locator<DetteRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  DialogService _dialogService = locator<DialogService>();
  String title = "On me prête";
  bool isLoading = true;
  bool isAlreadyRegistred = false;
  Obligation obligation = new Obligation();
  TextEditingController firstnameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController phoneTextController = TextEditingController();
  TextEditingController addressTextController = TextEditingController();
  TextEditingController dateCreatedAtController = TextEditingController();
  TextEditingController dateStartController = TextEditingController();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  UserInfos? userInfos;
  String currentUserfullname = "";
  bool personSelect = false;
  bool showPersonFormDetails = false;
  bool showPersonSelectType = false;
  bool canOpenPhoneContacts = false;
  bool isEdit = false;
  String otherPersonName = "";
  bool toConfirm = false;
  TextEditingController noteController = TextEditingController();
  TextEditingController dateDueController = TextEditingController();
  // Make sure obligation has currency field
  String currency = '€';
  ValueNotifier<bool> hasEmprunteur = ValueNotifier(false);
  final remboursement = TextEditingController();
  bool showContact = true;

  final formKey = GlobalKey<FormState>();
  var fileUrl = RxnString();
  ValueNotifier<bool> isFormValid = ValueNotifier(false);
  // nullable reactive
  AddObligationController(type, obligation) {
    if (obligation != null) {
      this.obligation = obligation;
      this.isEdit = true;
      print("Editing obligation: ${obligation.toJson()}");

      // ✅ Prefill form fields
      firstnameTextController.text = obligation.firstname ?? '';
      lastNameTextController.text = obligation.lastname ?? '';
      phoneTextController.text = obligation.tel ?? '';
      addressTextController.text = obligation.adress ?? '';
      noteController.text = obligation.note ?? '';
      dateStartController.text =
          DateFormat('yyyy-MM-dd').format(obligation.date);
      dateCreatedAtController.text = obligation.dateDisplay ?? '';
      dateDueController.text = obligation.dateStartDisplay ?? '';

      // ✅ Make sure form is visible
      this.tglePersonFormDetails();

      // ✅ Set names depending on type
      if (obligation.type == 'jed') {
        currentUserfullname = obligation.emprunteurName;
        otherPersonName = obligation.preteurName;
      } else if (obligation.type == 'onm' || obligation.type == 'amana') {
        currentUserfullname = obligation.preteurName;
        otherPersonName = obligation.emprunteurName;
      }
    }

    // Always set type and title
    this.obligation.type = type;
    this.title = "On me prête";
    if (type == 'jed') {
      this.title = "Je prête";
    } else if (type == 'amana') {
      this.title = 'Accord Amana';
    }

    // Default date
    var inputFormat = DateFormat("EEEE dd MMMM yyyy", 'fr_FR');
    dateCreatedAtController.text = inputFormat.format(this.obligation.date);

    notifyListeners();
  }

  // Example: call this on every field change
  void validateForm() {
    isFormValid.value = formKey.currentState?.validate() ?? false;
  }

  void updateDueDate(DateTime date) {
    obligation.dateStart = date; // model
    obligation.dateEndDisplay = DateFormat('dd/MM/yyyy').format(date);
    dateDueController.text = obligation.dateEndDisplay!;
    notifyListeners();
  }

// Method to update fileUrl

  void setFile(String? file) {
    obligation.file = file; // also store in your obligation map
    notifyListeners();
  }

  void setFileTranche(RxnString file) {
    fileUrl = file; // also store in your obligation map
    notifyListeners();
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // must match the key you used when saving
  }

  Future loadDatas() async {
    this.isLoading = false;
    this.canOpenPhoneContacts =
        await FlutterContacts.requestPermission(readonly: true);
    notifyListeners();
    if (this.obligation.id == null) {
      this.userInfos = await _userInfoReactiveService.getUserInfos(cache: true);
      if (this.userInfos != null) {
        this.currentUserfullname = this.userInfos!.fullname;
      }
    }
  }

  String accordEntre() {
    if (this.obligation.type == 'onm') {
      return "voici le détail de la reconnaissance de dette entre ";
    } else if (this.obligation.type == 'jed') {
      return "voici le détail de la reconnaissance de dette entre ";
    }
    return "voici le détail de la amana entre ";
  }

  getDateLabel() {
    if (this.obligation.type == 'onm') {
      return "Date du prêt";
    } else if (this.obligation.type == 'jed') {
      return "Date de l'emprunt";
    }
    return "Date de l'amana";
  }

  getPersonneLabel() {
    if (this.obligation.type == 'jed') {
      return "Ajouter un emprunteur";
    } else if (this.obligation.type == 'onm') {
      return "Ajouter un prêteur";
    }
    return "Ajouter une personne";
  }

  getPersonTypeLabel() {
    if (this.obligation.type == 'jed') {
      return "Prête à";
    } else if (this.obligation.type == 'onm') {
      return "Emprunte à";
    }
    return "et";
  }

  addPersonSelectType() {
    this.showPersonFormDetails = false;
    this.showPersonSelectType = true;
    hasEmprunteur.value = true;
    notifyListeners();
  }

  tglePersonFormDetails() {
    this.showPersonFormDetails = true;
    this.showPersonSelectType = true;
    notifyListeners();
  }

  saveObligation() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState!.save();
    }

    if (this.obligation.dateStart == null && this.obligation.type != 'amana') {
      _errorMessageService.showToaster(
        'error',
        "Merci de saisir une date d'échéance",
      );
      return;
    }

    this.isSaving.value = true;

    try {
      Map<String, dynamic> payload = {
        'id': obligation.id,
        'type': obligation.type,
        'amount': obligation.amount,
        'tel': obligation.tel,
        'firstname': obligation.firstname,
        'lastname': obligation.lastname,
        'note': obligation.note,
        'relatedUserId': obligation.relatedUserId,
        'fileUrl': obligation.fileUrl,
        'date': obligation.date?.toIso8601String(),
        'dateStart': obligation.dateStart?.toIso8601String(),
      };
      print("this is comming from AddObligationcontroller : ${payload}");

      print("filePath: ${obligation.file}");

      ApiResponse apiResponse =
          await _detteRepository.saveDette(payload, filePath: obligation.file);

      if (apiResponse.status == 200) {
        this.isSaving.value = false;
        this._navigationService.popRepeated(1);
      } else {
        this.isSaving.value = false;
        _errorMessageService.errorOnAPICall();
        // print the actual response data
        print('API returned error: ${apiResponse.data}');
      }
    } catch (t, stackTrace) {
      this.isSaving.value = false;
      print('Error occurred: $t');
      print('Stack trace: $stackTrace');

      if (t is DioError) {
        print('DioError details: ${t.response?.data}');
        print('Status code: ${t.response?.statusCode}');
      }
    }
  }

  updateDateCreated(DateTime date) {
    obligation.dateDisplay =
        DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(date);
    obligation.date = date;
    dateCreatedAtController.text = obligation.dateDisplay!;
  }

  void updateDate(DateTime date) {
    obligation.date = date; // model
    obligation.dateStartDisplay = DateFormat('dd/MM/yyyy').format(date);
    dateStartController.text = obligation.dateStartDisplay!;
    notifyListeners();
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

  searchContact() async {
    _navigationService
        .navigateWithTransition(
      SelectContactView(
        showContact: true,
      ),
      transitionStyle: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    )
        ?.then((value) {
      if (value != null) {
        if (value == 'showForm') {
          // User chose "Créer un contact" in SelectContactView
          tglePersonFormDetails();
        } else if (value is Relation) {
          Relation relation = value;
          this.obligation.firstname = relation.user.firstname;
          this.firstnameTextController.text = this.obligation.firstname;
          this.obligation.lastname = relation.user.lastname;
          this.lastNameTextController.text = this.obligation.lastname;
          this.obligation.adress = relation.user.city;
          this.addressTextController.text = this.obligation.adress;
          if (relation.user.phone != null) {
            this.obligation.tel = relation.user.phone!;
            this.phoneTextController.text = this.obligation.tel;
          }
          this.obligation.relatedUserId = relation.user.id;
          print(relation.user.id);
          tglePersonFormDetails();
        } else if (value is UserInfos) {
          // Phone contact selected
          obligation.firstname = value.firstname ?? '';
          firstnameTextController.text = obligation.firstname;

          obligation.lastname = value.lastname ?? '';
          lastNameTextController.text = obligation.lastname;

          obligation.tel = value.phone ?? '';
          phoneTextController.text = obligation.tel;

          addressTextController.text = obligation.adress;

          obligation.relatedUserId = value.id ?? null;
          print(obligation.firstname);

          tglePersonFormDetails();
        }
        notifyListeners();
      }
    });
  }

  raisonText() {
    if (this.obligation == null) {
      return 'Raison';
    } else if (this.obligation.type == 'jed') {
      return "Raison de l'emprunt";
    }
    return "Raison du prêt";
  }

  String moneyLabel() {
    String money = "Montant prêté";
    if (obligation?.type == 'onm') {
      money = "Montant emprunté";
    } else if (obligation?.type == 'amana') {
      money = "Montant de la amana";
    }
    return money;
  }

  Future<void> goToSelectContact({bool phoneContacts = false}) async {
    final result = await _navigationService.navigateWithTransition(
      phoneContacts ? ListPhoneContactView() : SelectContactView(),
      transitionStyle: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    );

    if (result != null) {
      if (result == 'showForm') {
        tglePersonFormDetails();

        notifyListeners();
      } else if (result is UserInfos) {
        // Prefill the form
        obligation.firstname = result.firstname ?? '';
        obligation.lastname = result.lastname ?? '';
        obligation.tel = result.phone ?? '';
        obligation.adress = result.city ?? '';
        obligation.relatedUserId = result.id ?? null;

        firstnameTextController.text = obligation.firstname;
        lastNameTextController.text = obligation.lastname;
        phoneTextController.text = obligation.tel;

        tglePersonFormDetails();
        notifyListeners();
      }
    }
  }

  void selectContact(UserInfos user) {
    // Return the selected contact to the previous view
    _navigationService.back(result: user);
  }
}

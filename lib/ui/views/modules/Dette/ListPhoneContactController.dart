import 'dart:async';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';


class ListPhoneContactController extends FutureViewModel<dynamic> {
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = false;
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  ListPhoneContactController();
  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    this.contacts = await FlutterContacts.getContacts(withProperties: true, withThumbnail: true);
    this.contactsFiltered = this.contacts;
    this.isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDatas() async {
    this.loadDatas();
  }

  searchContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(this.contacts);
    if(searchController.text.isNotEmpty) {
      _contacts.retainWhere((Contact contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        return false;
        // var phoneNum = contact.phones.firstWhere((phn) {
        //   String phnFlattened = flattenPhoneNumber(phn.number);
        //   return phnFlattened.contains(searchTermFlatten);
        // }, orElse: () => null);
        // return phoneNum != null;
      });
    }
    this.contactsFiltered = _contacts;
    notifyListeners();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  selectContact(contact) {
    this._navigationService.back(result: contact);
  }
  
}
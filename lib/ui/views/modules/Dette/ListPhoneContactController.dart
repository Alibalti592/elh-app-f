import 'dart:async';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
// 👉 Add this package to open Settings:
import 'package:app_settings/app_settings.dart';

class ListPhoneContactController extends FutureViewModel<dynamic> {
  final NavigationService _navigationService = locator<NavigationService>();

  bool isLoading = false;

  // Permission state exposed to the view
  bool permissionGranted = false;

  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future<void> loadDatas() async {
    isLoading = true;
    notifyListeners();

    // ✅ Ask/confirm permission every time we come to this page
    permissionGranted = await FlutterContacts.requestPermission(readonly: true);

    if (!permissionGranted) {
      // Don’t try to read contacts; just stop here
      contacts = [];
      contactsFiltered = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    // ✅ Permission OK → fetch contacts
    contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
    );
    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    contactsFiltered = List<Contact>.from(contacts);

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDatas() async {
    await loadDatas();
  }

  // Open OS settings so the user can enable Contacts later
  Future<void> openSettings() async {
    await AppSettings.openAppSettings();
  }

  void searchContact() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      contactsFiltered = List<Contact>.from(contacts);
      notifyListeners();
      return;
    }

    final flatQ = _flattenPhone(q);
    contactsFiltered = contacts.where((c) {
      final nameHit = c.displayName.toLowerCase().contains(q);
      final phoneHit =
          c.phones.any((p) => _flattenPhone(p.number).contains(flatQ));
      return nameHit || phoneHit;
    }).toList();

    notifyListeners();
  }

  String _flattenPhone(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

  void selectContact(Contact contact) {
    _navigationService.back(result: contact);
  }
}

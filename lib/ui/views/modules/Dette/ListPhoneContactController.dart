import 'dart:async';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_settings/app_settings.dart';

class ListPhoneContactController extends FutureViewModel<dynamic> {
  final NavigationService _navigationService = locator<NavigationService>();

  // STATES
  bool hasCheckedPermission = false; // initial permission check completed
  bool permissionGranted = false;
  bool isLoading = false; // loading contacts only

  List<Contact> contacts = [];

  // Search
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future<void> loadDatas() async {
    // 1) Check (and if needed, request) permission first (no spinner)
    permissionGranted = await FlutterContacts.requestPermission(readonly: true);
    hasCheckedPermission = true;
    notifyListeners();

    if (!permissionGranted) {
      contacts = [];
      return; // show stable NoPermission screen, no flicker
    }

    // 2) Load contacts with spinner
    isLoading = true;
    notifyListeners();
    try {
      contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDatas() async {
    // Re-check permission (this will return immediately if already granted)
    permissionGranted = await FlutterContacts.requestPermission(readonly: true);
    notifyListeners();

    if (!permissionGranted) return;

    isLoading = true;
    notifyListeners();
    try {
      contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openSettings() async {
    await AppSettings.openAppSettings();
    // When coming back, your view's didChangeAppLifecycleState calls refreshDatas()
  }

  void selectContact(Contact contact) =>
      _navigationService.back(result: contact);

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

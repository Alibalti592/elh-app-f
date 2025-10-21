import 'dart:async';
import 'package:elh/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_settings/app_settings.dart';

// ListPhoneContactController.dart  (unchanged core)
class ListPhoneContactController extends FutureViewModel<dynamic> {
  final NavigationService _navigationService = locator<NavigationService>();

  bool isLoading = false;
  bool permissionGranted = false;

  List<Contact> contacts = [];

  // We keep ONE controller here to persist across rebuilds
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future<void> loadDatas() async {
    isLoading = true;
    notifyListeners();

    permissionGranted = await FlutterContacts.requestPermission(readonly: true);

    if (!permissionGranted) {
      contacts = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
    );
    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));

    // DEBUG

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDatas() async => loadDatas();

  Future<void> openSettings() async => AppSettings.openAppSettings();

  void selectContact(Contact contact) =>
      _navigationService.back(result: contact);

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

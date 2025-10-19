import 'package:elh/locator.dart';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:stacked/stacked.dart';

class LocationStore with ListenableServiceMixin {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  Bblocation? selectedLocation;

  LocationStore() {
    listenToReactiveValues([selectedLocation]);
  }

  setLocation(location) {
    selectedLocation = location;
  }
}

import 'package:elh/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DeceNavController extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();

  navigateTo(view) {
    _navigationService.navigateToView(view);
  }
}
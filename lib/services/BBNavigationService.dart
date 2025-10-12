import 'package:flutter/widgets.dart';
import 'package:elh/locator.dart';
import 'package:stacked_services/stacked_services.dart';

class BBNavigationService {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  NavigationService _navigationService = locator<NavigationService>();
  String? fromViewName;
  bool? hasToRefresh;

  //enregistrer la vue précédente
  void setFromView(viewName) {
    this.fromViewName = viewName;
  }

  void setHasToRefreshView(hasToRefresh) {
    this.hasToRefresh = hasToRefresh;
  }

  Future<dynamic>? navigateTo(String routeName) {
    return navigatorKey.currentState?.pushNamed(routeName);
  }

  Future<dynamic>? clearStackAndGoTo(Widget view) {
    return _navigationService.clearTillFirstAndShowView(view);
  }
}
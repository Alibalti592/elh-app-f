import 'dart:async';
import 'package:elh/locator.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:stacked/stacked.dart';

class QiblahController extends StreamViewModel {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  // QiblahDirection qiblahDirection;
  double angle = 50.0;
  ValueNotifier<bool> aligne = ValueNotifier<bool>(false);

  @override
  Stream get stream => snapshotChange();

  snapshotChange() {
    // return StreamController<LocationStatus>.broadcast();
    return FlutterQiblah.qiblahStream;
  }

  steamData() async {
    return FlutterQiblah.qiblahStream;
  }






}
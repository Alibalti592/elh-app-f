import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:elh/locator.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui' as ui;

class SalatCardController extends BaseViewModel {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  bool isLoading = false;
  ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);
  Salat salat;
  final GlobalKey globalKey = new GlobalKey();
  bool shareDirect = false;

  SalatCardController({required this.salat, this.shareDirect = false}) {
    this.salat = salat;
    if(this.shareDirect) {
      this.shareSalat();
    }
  }

  closeIt() {

  }

  shareSalat() async {
    try {
      this.isSharing.value = true;
      Future.delayed(const Duration(milliseconds: 300)).then((val) async { //time to button disappear
        RenderRepaintBoundary boundary = this.globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();
        var bs64 = base64Encode(pngBytes);
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath + '/salat-al-janaza.png';
        File imgFile = await File(filePath).writeAsBytes(pngBytes);
        XFile imageToShare = XFile.fromData(pngBytes);
        // Share.shareXFiles([imageToShare], text: "Salât al-janaza, ${salat.firstname} ${salat.lastname}");
        final result = await Share.shareXFiles(
            [XFile(filePath)], sharePositionOrigin:  Rect.fromPoints(const Offset(2, 2), const Offset(3, 3))
        );
        File(filePath).delete();
        this.isSharing.value = false;
      });
    } catch (e) {
      print(e);
      this.isSharing.value = false;
    }
  }

}
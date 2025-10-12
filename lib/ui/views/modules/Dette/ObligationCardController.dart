import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:elh/locator.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui' as ui;

class ObligationCardController extends BaseViewModel {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  bool isLoading = false;
  ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);
  Obligation obligation;
  String title = "Je dois";
  final GlobalKey globalKey = new GlobalKey();

  ObligationCardController(directShare, {required this.obligation}) {
    this.obligation = obligation;
    if(obligation.type == 'onm') {
      this.title = 'On me doit';
    }
    if(directShare) {
      this.shareObligation();
    }
  }


  shareObligation() async {
    try {
      this.isSharing.value = true;
      Future.delayed(const Duration(milliseconds: 250)).then((val) async { //time to button disappear
        RenderRepaintBoundary boundary = this.globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();
        var bs64 = base64Encode(pngBytes);
        String fullname1 = "${obligation.firstname} ${obligation.lastname}";
        String slug1 = this.generateSlug(fullname1);
        String fullname2 = "${obligation.createdByName}";
        String slug2 = this.generateSlug(fullname2);
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath + '/reconnaissance-dette-$slug2-$slug1.png';
        File imgFile = await File(filePath).writeAsBytes(pngBytes);
        XFile imageToShare = XFile.fromData(pngBytes);
        String title = 'Reconnaissance de dette entre $fullname1 et $fullname2';
        final result = await Share.shareXFiles([XFile(filePath)], text: title);
        File(filePath).delete();
        this.isSharing.value = false;
      });
    } catch (e) {
      this.isSharing.value = false;
    }
  }

  String generateSlug(String name) {
    return name
        .toLowerCase() // Convert to lowercase
        .trim() // Remove leading and trailing spaces
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-'); // Remove multiple hyphens
  }

  raisonText(obligation) {
    return 'Raison de la dette';
  }

}
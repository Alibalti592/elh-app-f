import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/TestamentService.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/views/modules/Testament/EditTestamentView.dart';
import 'package:elh/ui/views/modules/Testament/ShareToView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_contacts/diacritics.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/models/Obligation.dart';
import 'dart:ui' as ui;

class MyTestamentController extends FutureViewModel<dynamic> {
  NavigationService _navigationService = locator<NavigationService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  TestamentRepository _testamentRepository = locator<TestamentRepository>();
  UserInfoReactiveService _userInfoReactiveService = locator<UserInfoReactiveService>();
  TestamentService _testamentService = locator<TestamentService>();
  bool isLoading = false;
  bool pdfLoading = false;
  List<Obligation> jeds = [];
  List<Obligation> onms = [];
  List<Obligation> amanas = [];
  String joursJeun = "Aucun jour à rattraper";
  Testament? testament;
  int tabIndex = 0;
  UserInfos? userInfos;
  List<Obligation> obligations = [];
  final GlobalKey globalKey = new GlobalKey();
  int page = 0;

  @override
  Future<dynamic> futureToRun() => loadDatas();

  setPage(page) {
    this.page = page;
    notifyListeners();
  }

  loadDatas() async {
    this.loadJeunText();
    this.loadTestament();
  }

  Future loadJeunText() async {
    ApiResponse apiResponse = await _testamentRepository.loadJeuntext(this.testament);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      this.joursJeun = data['jeunText'];
    }
  }

  Future loadTestament() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.loadTestament();
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      this.testament = testamentFromJson(data['testament']);
      await this.loadDettes();
      this.isLoading = false;
      notifyListeners();
    } else {
      this.isLoading = false;
      _errorMessageService.errorOnAPICall();
    }
    this.userInfos = await _userInfoReactiveService.getUserInfos(cache: true);
  }

  Future loadDettes() async {
    var dettes = await _testamentService.loadDettes(this.testament!);
    this.jeds = dettes['jeds'];
    this.onms = dettes['onms'];
    this.amanas = dettes['amanas'];
  }


  Future<void> refreshDatas() async {
    this.isLoading = true;
    notifyListeners();
    this.loadDatas();
  }

  editTestament() {
    _navigationService.navigateWithTransition(EditTestamentView(this.testament))?.then((value) {
      this.loadDatas();
    });
  }

  shareTestament() {
    _navigationService.navigateWithTransition(ShareToView())?.then((value) {
      this.loadDatas();
    });
  }


  downloadTestament() {
    try {
      Future.delayed(const Duration(milliseconds: 50)).then((val) async { //time to button disappear
        RenderRepaintBoundary boundary = this.globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();

        // var bs64 = base64Encode(pngBytes);
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath + '/testament-muslim-connect.png';
        File imgFile = await File(filePath).writeAsBytes(pngBytes);
        XFile imageToShare = XFile.fromData(pngBytes);
        // Share.shareXFiles([imageToShare], text: "Salât al-janaza, ${carte.firstname} ${carte.lastname}");
        final result = await Share.shareXFiles([XFile(filePath)], text: "Testament de ${this.userInfos!.fullname}");
        File(filePath).delete();
      });
    } catch (e) {

    }
  }


  exportAsPdf() async {
    this.pdfLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await _testamentRepository.getPdfLink(this.testament!);
    if (apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      String s3PdfUrl = data['url'];
      try {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }
        if (directory == null) {
          _errorMessageService.errorShoMessage("Impossible d'accéder aux dossier de votre téléphone pour télécharger le fichier");
        } else {
          String from = this.testament!.from == null ? "nd" : this.testament!.from!;
          String filename = generateSlug(from);
          String filePath = '${directory!.path}/$filename';
          Dio dio = Dio();
          await dio.download(s3PdfUrl, filePath);
          OpenFile.open(filePath);
        }
      } catch(e) {
        _errorMessageService.errorShoMessage("Erreur lors de l'ouverture du document, merci de regarder vos documents téléchargés");
      }
      this.pdfLoading = false;
      notifyListeners();

    }
  }

  String generateSlug(String name) {
    // Supprime les accents et met en minuscules
    String slug = removeDiacritics(name).toLowerCase();
    slug = slug.replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(' ', '_');
    return "testament_$slug.pdf"; // Ex: document_nicolas_beudos.pdf
  }


}
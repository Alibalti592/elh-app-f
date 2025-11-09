import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/repository/CarteRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui' as ui;

class CarteCardController extends FutureViewModel<dynamic> {
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  CarteRepository _carteRepository = locator<CarteRepository>();
  bool isLoading = false;
  ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);
  Carte carte;
  String? mainText;
  bool shareDirect = false;

  final GlobalKey globalKey = new GlobalKey();
  CarteCardController({required this.carte, this.shareDirect = false}) {
    this.carte = carte;
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  Future loadDatas() async {
    this.isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await _carteRepository.loadTextContent(this.carte.id);
    if (apiResponse.status == 200) {
      this.mainText = json.decode(apiResponse.data)['mainText'];
      notifyListeners();
      if (this.shareDirect) {
        this.shareCarte();
      }
    } else {
      _errorMessageService.errorOnAPICall();
    }
  }

  String getTopArabique() {
    if (this.carte.type == 'death') {
      return "إن لله و إن إليه راجعون";
    } else {
      return "بارك الله فيك /  فيكم";
    }
  }

  String getTitle() {
    if (this.carte.type == 'death') {
      return "Suite au décès de notre ${carte.afiliationLabel}";
    } else {
      return "Suite à la maladie de notre ${carte.afiliationLabel}";
    }
  }

  String getDescription() {
    if (this.carte.type == 'death') {
      return "C’est avec une grande tristesse que nous vous annonçons le décès de notre ${carte.afiliationLabel}";
    } else {
      return "";
    }
  }

  String getBottom() {
    if (this.carte.type == 'death') {
      return "Inna lillahi wa inna ilayhi raji'un\nإِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ";
    } else {
      return "Qu'Allah vous accorde Jannah Al Firdaws";
    }
  }

  String getMiddleRamhou() {
    if (this.carte.sex == 'm') {
      return "Allah y rhamo";
    } else {
      return "Allah y rhamaha";
    }
  }

  shareCarte() async {
    try {
      this.isSharing.value = true;
      Future.delayed(const Duration(milliseconds: 300)).then((val) async {
        //time to button disappear
        RenderRepaintBoundary boundary = this
            .globalKey
            .currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();

        var bs64 = base64Encode(pngBytes);
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath + '/carte-muslim-connect.png';
        File imgFile = await File(filePath).writeAsBytes(pngBytes);
        XFile imageToShare = XFile.fromData(pngBytes);
        // Share.shareXFiles([imageToShare], text: "Salât al-janaza, ${carte.firstname} ${carte.lastname}");
        final result = await Share.shareXFiles([XFile(filePath)]);
        File(filePath).delete();
        this.isSharing.value = false;
      });
    } catch (e) {
      print(e);
      this.isSharing.value = false;
    }
  }

  // static Future<Uint8List?> createImageFromWidget(BuildContext context, Widget widget, { Duration? wait, Size? logicalSize, Size? imageSize }) async {
  //   final repaintBoundary = RenderRepaintBoundary();
  //
  //   logicalSize ??= View.of(context).physicalSize / View.of(context).devicePixelRatio;
  //   imageSize ??= View.of(context).physicalSize;
  //
  //   assert(logicalSize.aspectRatio == imageSize.aspectRatio,
  //   'logicalSize and imageSize must not be the same');
  //
  //   final renderView = RenderView(
  //       child: RenderPositionedBox(
  //           alignment: Alignment.center, child: repaintBoundary),
  //       configuration: ViewConfiguration(
  //         size: logicalSize,
  //         devicePixelRatio: 1,
  //       ),
  //       view: View.of(context) //PlatformDispatcher.instance.views.first,
  //   );
  //
  //   final pipelineOwner = PipelineOwner();
  //   final buildOwner = BuildOwner(focusManager: FocusManager());
  //
  //   pipelineOwner.rootNode = renderView;
  //   renderView.prepareInitialFrame();
  //
  //   final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
  //       container: repaintBoundary,
  //       child: Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: widget,
  //       )).attachToRenderTree(buildOwner);
  //
  //   buildOwner.buildScope(rootElement);
  //
  //   if (wait != null) {
  //     await Future.delayed(wait);
  //   }
  //
  //   buildOwner
  //     ..buildScope(rootElement)
  //     ..finalizeTree();
  //
  //   pipelineOwner
  //     ..flushLayout()
  //     ..flushCompositingBits()
  //     ..flushPaint();
  //
  //   final image = await repaintBoundary.toImage(
  //       pixelRatio: imageSize.width / logicalSize.width);
  //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //
  //   return byteData?.buffer.asUint8List(); //pngBytes
  // }
}

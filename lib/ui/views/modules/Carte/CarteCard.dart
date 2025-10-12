import 'package:elh/common/theme.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/CustomRectTween.dart';
import 'package:elh/ui/views/modules/Carte/CarteCardController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class CarteCard extends StatefulWidget {
  final Carte carte;
  bool shareDirect = false;
  CarteCard({required this.carte, this.shareDirect = false});
  @override
  CarteCardState createState() =>
      CarteCardState(carte: carte, shareDirect: this.shareDirect);
}

class CarteCardState extends State<CarteCard> {
  Carte carte;
  bool shareDirect = false;
  CarteCardState({required this.carte, this.shareDirect = false}) {
    this.carte = carte;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarteCardController>.reactive(
        viewModelBuilder: () =>
            CarteCardController(carte: carte, shareDirect: this.shareDirect),
        builder: (context, controller, child) => Center(
              child: LayoutBuilder(builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double containerWidth =
                    screenWidth * 0.98; // 95% of screen width
                double containerHeight = containerWidth * (1350 / 1080);
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Hero(
                    tag: "carte-tag-${carte.id}",
                    createRectTween: (begin, end) {
                      return CustomRectTween(begin: begin, end: end);
                    },
                    child: ListView(
                      children: [
                        RepaintBoundary(
                          key: controller.globalKey,
                          child: Material(
                            color: primaryColor,
                            elevation: 2,
                            child: Container(
                              width: containerWidth,
                              height: containerHeight,
                              decoration:
                                  BoxDecoration(image: backgroundImageSimple()),
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: SizedBox(
                                          width: 150,
                                          height: 120,
                                          child: Image.asset(
                                            'assets/images/rosace.png',
                                            fit: BoxFit.contain,
                                            // color: primaryColor.withOpacity(0.4),
                                            // colorBlendMode: BlendMode.modulate,
                                          ))),
                                  // rosace.png
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15,
                                          bottom: 10,
                                          left: 20,
                                          right: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          UIHelper.verticalSpace(15),
                                          // Text(controller.getTopArabique(),
                                          //   style: TextStyle(color: white, fontFamily: 'Karla', fontWeight: FontWeight.w600, fontSize: 23),
                                          //   textAlign: TextAlign.center,
                                          // ),
                                          UIHelper.verticalSpace(2),
                                          controller.carte.type == 'death'
                                              ? Column(
                                                  children: [
                                                    Text("Assalem Alaykoum",
                                                        style: TextStyle(
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 19)),
                                                    UIHelper.verticalSpace(5),
                                                    //Text intro
                                                    Text(
                                                      controller
                                                          .getDescription(),
                                                      style: TextStyle(
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    UIHelper.verticalSpace(10),
                                                    _item(
                                                        SizedBox(
                                                          width: 35,
                                                          child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Icon(Icons
                                                                  .person_outlined)),
                                                        ),
                                                        "${carte.firstname} ${carte.lastname}"),
                                                    UIHelper.verticalSpace(10),
                                                    carte.type == 'death'
                                                        ? _item(
                                                            Icon(MdiIcons
                                                                .calendarOutline),
                                                            carte.dateDisplay)
                                                        : Container(),
                                                    carte.type == 'death'
                                                        ? UIHelper
                                                            .verticalSpace(10)
                                                        : Container(),
                                                    carte.type == 'death'
                                                        ? _item(
                                                            Icon(MdiIcons
                                                                .mapMarkerOutline),
                                                            carte.locationName)
                                                        : Container(),
                                                    carte.type == 'death'
                                                        ? Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10),
                                                            child: Text(
                                                              controller
                                                                  .getMiddleRamhou(),
                                                              style: TextStyle(
                                                                  color: white,
                                                                  fontFamily:
                                                                      'Karla',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 17),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          )
                                                        : Container(),
                                                    carte.content.length > 1
                                                        ? Column(
                                                            children: [
                                                              UIHelper
                                                                  .verticalSpace(
                                                                      10),
                                                              _item(Container(),
                                                                  carte.content,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ],
                                                          )
                                                        : Container(),
                                                    UIHelper.verticalSpace(10),
                                                    Text(
                                                      controller.getBottom(),
                                                      style: TextStyle(
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    UIHelper.verticalSpace(10),
                                                  ],
                                                )
                                              : Container(),

                                          controller.mainText != null
                                              ? Container(
                                                  child: Text(
                                                    controller.mainText!,
                                                    style: TextStyle(
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14.5),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Container(),
                                          UIHelper.verticalSpace(5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder<bool>(
                                    builder: (BuildContext context,
                                        bool isSharing, Widget? child) {
                                      return isSharing
                                          ? Container(height: 10)
                                          : Positioned(
                                              top: 10,
                                              right: 5,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close,
                                                    color: Colors.white,
                                                    size: 18),
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 1,
                                                    shape: CircleBorder(),
                                                    padding: EdgeInsets.all(10),
                                                    backgroundColor:
                                                        Colors.black54),
                                              ));
                                    },
                                    valueListenable: controller.isSharing,
                                  ),
                                  //pbs le bouton est dessus : cacher le bout onClick ?!
                                  ValueListenableBuilder<bool>(
                                    builder: (BuildContext context,
                                        bool isSharing, Widget? child) {
                                      return isSharing
                                          ? Container(height: 50)
                                          : Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: GestureDetector(
                                                  child: ElevatedButton(
                                                onPressed: () {
                                                  controller.shareCarte();
                                                },
                                                child: Icon(
                                                    MdiIcons
                                                        .shareVariantOutline,
                                                    color: Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                    shape: CircleBorder(),
                                                    padding: EdgeInsets.all(24),
                                                    backgroundColor: darken(
                                                        primaryColor, 0.1)),
                                              )));
                                    },
                                    valueListenable: controller.isSharing,
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Image(
                                          image: AssetImage(
                                              "assets/images/logo-no-bg.png"),
                                          height: 70),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ));
  }

  Widget _item(icon, text, {title, fontWeight = FontWeight.w700}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0x94ffffff),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            icon,
            UIHelper.horizontalSpace(15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title != null
                    ? SizedBox(
                        width: 150,
                        child: Text(title, style: TextStyle(color: fontGrey)))
                    : Container(),
                title != null ? UIHelper.verticalSpace(5) : Container(),
                Container(
                    width: 190,
                    child: Text(text,
                        style: TextStyle(
                            fontWeight: fontWeight,
                            fontSize: 14,
                            color: Colors.black)))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

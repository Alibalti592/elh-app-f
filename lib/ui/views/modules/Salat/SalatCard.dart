import 'dart:math' as math;

import 'package:elh/common/theme.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/CustomRectTween.dart';
import 'package:elh/ui/views/modules/Salat/SalatCardController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class SalatCard extends StatefulWidget {
  final Salat salat;
  bool shareDirect = false;
  SalatCard({required this.salat, this.shareDirect = false});
  @override
  SalatCardState createState() =>
      SalatCardState(salat: salat, shareDirect: this.shareDirect);
}

class SalatCardState extends State<SalatCard> {
  Salat salat;
  bool shareDirect = false;
  SalatCardState({required this.salat, this.shareDirect = false}) {
    this.salat = salat;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalatCardController>.reactive(
      viewModelBuilder: () =>
          SalatCardController(salat: salat, shareDirect: this.shareDirect),
      builder: (context, controller, child) => Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double containerWidth = screenWidth * 0.98; // 95% of screen width
            double targetHeight = containerWidth * (2000 / 1080);
            double maxHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight * 0.98
                : targetHeight;
            double containerHeight = math.min(targetHeight, maxHeight);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Hero(
                tag: "salat-tag-${salat.id}",
                createRectTween: (begin, end) {
                  return CustomRectTween(begin: begin, end: end);
                },
                child: RepaintBoundary(
                  key: controller.globalKey,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 6,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: primaryColorLight,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.08)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(35, 0, 0, 0),
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 6,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SizedBox(
                                  width: 220,
                                  height: 130,
                                  child: Image.asset(
                                    'assets/images/rosace.png',
                                    fit: BoxFit.contain,
                                    color: Colors.white.withOpacity(0.08),
                                    colorBlendMode: BlendMode.srcATop,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 80, left: 18, right: 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  UIHelper.verticalSpace(45),
                                  Text(
                                    'Salât Al-Janaza',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  UIHelper.verticalSpace(8),
                                  Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(8),
                                  _item(
                                    MdiIcons.accountOutline,
                                    "${salat.firstname} ${salat.lastname}",
                                    title: "Sur notre ${salat.afiliationLabel}",
                                  ),
                                  UIHelper.verticalSpace(6),
                                  _item(
                                    MdiIcons.calendarOutline,
                                    salat.dateDisplay,
                                  ),
                                  UIHelper.verticalSpace(6),
                                  _item(
                                    MdiIcons.clockOutline,
                                    salat.timeDisplay,
                                  ),
                                  salat.mosque != null
                                      ? Column(
                                          children: [
                                            UIHelper.verticalSpace(6),
                                            _item(
                                              MdiIcons.mosqueOutline,
                                              salat.mosque!.name,
                                              title: "Mosquée",
                                            ),
                                            UIHelper.verticalSpace(6),
                                            _item(
                                              MdiIcons.mapMarkerOutline,
                                              "${salat.mosque!.location.adress}${salat.mosque!.location.adress != '' ? ',' : ''} ${salat.mosque!.location.city}",
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  UIHelper.verticalSpace(6),
                                  salat.mosque == null && salat.mosqueName != ""
                                      ? Column(
                                          children: [
                                            UIHelper.verticalSpace(6),
                                            _item(
                                              MdiIcons.mosqueOutline,
                                              salat.mosqueName,
                                              title: "Mosquée",
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  UIHelper.verticalSpace(6),
                                  _item(
                                    MdiIcons.graveStone,
                                    salat.cimetary,
                                    title: 'Cimetière',
                                  ),
                                  UIHelper.verticalSpace(12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.16)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Inna lillah wa inna ilayhi raji’un",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.5,
                                            color: Colors.white,
                                            fontFamily: 'Karla',
                                            letterSpacing: 0.25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        UIHelper.verticalSpace(6),
                                        Text(
                                          "إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  UIHelper.verticalSpace(10),
                                ],
                              ),
                            ),
                            //CLOSE
                            ValueListenableBuilder<bool>(
                              builder: (BuildContext context, bool isSharing,
                                  Widget? child) {
                                return isSharing
                                    ? Container(height: 10)
                                    : Positioned(
                                        top: 10,
                                        right: 5,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 18),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(10),
                                            backgroundColor:
                                                Colors.white.withOpacity(0.2),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      );
                              },
                              valueListenable: controller.isSharing,
                            ),
                            //pbs le bouton est dessus : cacher le bout onClick ?!
                            ValueListenableBuilder<bool>(
                              builder: (BuildContext context, bool isSharing,
                                  Widget? child) {
                                return isSharing
                                    ? Container(height: 50)
                                    : Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              controller.shareSalat();
                                            },
                                            child: Icon(
                                                MdiIcons.shareVariantOutline,
                                                color: Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(24),
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.2),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                      );
                              },
                              valueListenable: controller.isSharing,
                            ),
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Image(
                                  image: const AssetImage(
                                      "assets/images/logo-no-bg.png"),
                                  height: 70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _item(IconData icon, String? text,
      {String? title,
      FontWeight fontWeight = FontWeight.w700,
      double fontSize = 19.0}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 8))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                primaryColor.withOpacity(0.95),
                darken(primaryColor, 0.1).withOpacity(0.85)
              ]),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(14, 0, 0, 0),
                    blurRadius: 7,
                    offset: Offset(0, 3))
              ],
              border: Border.all(color: primaryColor.withOpacity(0.4)),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          UIHelper.horizontalSpace(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2),
                  ),
                Text(
                  text ?? '',
                  style: TextStyle(
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                    color: Colors.white,
                    height: 1.25,
                    fontFamily: 'Karla',
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

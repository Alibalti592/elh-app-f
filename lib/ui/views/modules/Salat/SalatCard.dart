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
  SalatCardState createState() => SalatCardState(salat: salat, shareDirect: this.shareDirect);
}

class SalatCardState extends State<SalatCard>  {
  Salat salat;
  bool shareDirect = false;
  SalatCardState({required this.salat, this.shareDirect = false}) {
    this.salat = salat;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalatCardController>.reactive(
        viewModelBuilder: () => SalatCardController(salat: salat, shareDirect: this.shareDirect),
    builder: (context, controller, child) => Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double containerWidth = screenWidth * 0.98; // 95% of screen width
          double containerHeight = containerWidth * (1350 / 1080);
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
                  color: primaryColor,
                  elevation: 2,
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                        image: backgroundImageSimple()
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                                width: 200,
                                height: 120,
                                child: Image.asset(
                                  'assets/images/rosace.png',
                                  fit: BoxFit.contain,
                                  // color: primaryColor.withOpacity(0.4),
                                  // colorBlendMode: BlendMode.modulate,
                                ))
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 20, right: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Salât Al-Janaza', style: TextStyle(
                                    color: white,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22),),
                                UIHelper.verticalSpace(7),
                                _item(MdiIcons.accountOutline,
                                    "${salat.firstname} ${salat.lastname}",
                                    title: "Sur notre ${salat
                                        .afiliationLabel}"),
                                UIHelper.verticalSpace(7),
                                _item(
                                    MdiIcons.calendarOutline, salat.dateDisplay,
                                    title: 'Date de la Salat'),
                                UIHelper.verticalSpace(7),
                                _item(MdiIcons.clockOutline, salat.timeDisplay,
                                    title: 'Heure de la Salat'),
                                salat.mosque != null ? Column(
                                  children: [
                                    UIHelper.verticalSpace(7),
                                    _item(MdiIcons.mosqueOutline,
                                        salat.mosque!.name, title: "Mosquée"),
                                    UIHelper.verticalSpace(7),
                                    _item(MdiIcons.mapMarkerOutline,
                                        "${salat.mosque!.location.adress}${salat
                                            .mosque!.location.adress != ''
                                            ? ','
                                            : '' } ${salat.mosque!.location
                                            .city}",
                                        title: "Localisation de la mosquée",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0),
                                  ],
                                ) : Container(),
                                UIHelper.verticalSpace(7),
                                salat.mosque == null && salat.mosqueName != ""
                                    ? Column(
                                  children: [
                                    UIHelper.verticalSpace(7),
                                    _item(MdiIcons.mosqueOutline,
                                        salat.mosqueName, title: "Mosquée"),
                                  ],
                                )
                                    : Container(),
                                UIHelper.verticalSpace(7),
                                _item(MdiIcons.graveStone, salat.cimetary,
                                    title: 'Cimetière'),
                                // salat.content.length > 1 ? Column(
                                //   children: [
                                //     UIHelper.verticalSpace(15),
                                //     _item(MdiIcons.pencilOutline, salat.content),
                                //   ],
                                // ) : Container(),
                                UIHelper.verticalSpace(7),
                                // Text("Le messager d'Allah a dit : "
                                //     "il n’y a aucun mort sur qui prie un groupe de musulmans dont le"
                                //     "nombre atteint cent, tous invoquant pour lui, sans que leurs demandes"
                                //     "(pour le mort) ne soient acceptées",
                                //     style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white,
                                //         fontFamily: 'Karla'),
                                //   textAlign: TextAlign.center,
                                // ),
                                Text("Inna lillah wa inna ilayhi raji’un",
                                  style: TextStyle(fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: 'Karla'),
                                  textAlign: TextAlign.center,
                                ),
                                UIHelper.verticalSpace(4),
                              ],
                            ),
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
                                  child: Icon(Icons.close, color: Colors.white,
                                      size: 18),
                                  style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(10),
                                      backgroundColor: Colors.black54
                                  ),
                                )
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
                                      child: Icon(MdiIcons.shareVariantOutline,
                                          color: Colors.white),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(24),
                                          backgroundColor: darken(
                                              primaryColor, 0.1)
                                      ),
                                    )
                                )
                            );
                          },
                          valueListenable: controller.isSharing,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image(image: AssetImage("assets/images/logo-no-bg.png"), height: 70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      )
    ));
  }

  Widget _item(icon, text, {title, fontWeight = FontWeight.w700, fontSize = 13.0 }) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
                minHeight: 35, minWidth: double.infinity),
            decoration: BoxDecoration(
              color: Color(0xfffcedde),
              borderRadius: BorderRadius.circular(30),
            ),
            margin: const EdgeInsets.only(left: 15),
            padding: const EdgeInsets.only(top: 2, left: 0, right: 15, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIHelper.horizontalSpace(15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    title != null ? Text(title, style: TextStyle(color: fontGrey,fontSize: 10 ), textAlign: TextAlign.center, ) : Container(),
                    Container(
                      width: 190,
                        child: Text(text, style: TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: Colors.black),  textAlign: TextAlign.center)
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: bgLightV2,
                  border: Border.all(color: fontGrey),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical:5),
                child: Icon(icon, color: Colors.black54))
          ),
        ],
      ),
    );
  }

}
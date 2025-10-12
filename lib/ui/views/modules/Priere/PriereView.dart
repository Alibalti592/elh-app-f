import 'package:elh/common/theme.dart';
import 'package:elh/models/Praytime.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Priere/PriereController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:elh/ui/views/modules/Qiblah/QiblahView.dart';

class PriereView extends StatefulWidget {
  @override
  PriereViewState createState() => PriereViewState();
}

class PriereViewState extends State<PriereView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      true; //AutomaticKeepAliveClientMixin eviter rebuild au changement page

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PriereController>.reactive(
        viewModelBuilder: () => PriereController(),
        builder: (context, controller, child) => Scaffold(
            appBar: AppBar(
              leadingWidth: 60,
              toolbarHeight: 60,
              titleSpacing: 0,
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              title: Text("Heures de prières", style: headerTextWhite),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1.0), // light beige
                      Color.fromRGBO(143, 151, 121, 1.0), // olive green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            backgroundColor: bgLight,
            extendBody: true,
            body: controller.isLoading
                ? BBloader()
                : RefreshIndicator(
                    onRefresh: controller.loadDatas,
                    child: ListView(
                      children: [
                        controller.needDefineLocation
                            ? Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    Text(
                                        'Pour visualiser les heures de prière merci de préciser votre localisation',
                                        style: TextStyle(fontSize: 17),
                                        textAlign: TextAlign.center),
                                    UIHelper.verticalSpace(20),
                                    GestureDetector(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        controller.setLocation();
                                      },
                                      child: Icon(MdiIcons.homeSearch,
                                          color: Colors.white),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(12),
                                          backgroundColor: Color(0xFFBE914F)),
                                    ))
                                  ],
                                ))
                            : Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: primaryColor),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Center(
                                        child: Image(
                                            image: AssetImage(
                                                "assets/images/logo-no-bg.png"),
                                            height: 90),
                                      ),
                                    ),
                                    // --- Qiblah Compass Widget ---

                                    __nextPray(controller),

                                    UIHelper.verticalSpace(
                                        25), // optional spacing
                                  ],
                                )),
                        controller.needDefineLocation
                            ? Container()
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 15),
                                child: Column(children: praytimes(controller)),
                              )
                      ],
                    ),
                  )));
  }

  List<Widget> praytimes(PriereController controller) {
    List<Widget> prays = [];
    controller.praytime!.prieres.forEach((priere) {
      prays.add(pray(controller, priere));
      prays.add(UIHelper.verticalSpace(10));
    });
    return prays;
  }

  Widget pray(PriereController controller, Priere priere) {
    String imageName = 'Icon_Fajr';
    if (priere.key == 'chorouq') {
      imageName = 'Sunrise';
    } else if (priere.key == 'dohr') {
      imageName = 'Icon_Dhuhr';
    } else if (priere.key == 'asr') {
      imageName = 'Icon_Asr';
    } else if (priere.key == 'maghreb') {
      imageName = 'Icon_Maghrib';
    } else if (priere.key == 'icha') {
      imageName = 'Icon_Isha';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 3)
        ],
      ),
      child: Row(
        children: [
          Expanded(
              flex: 6,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icon/$imageName.svg',
                    color: fontGreyDark,
                    height: 25,
                    fit: BoxFit.fill,
                  ),
                  UIHelper.horizontalSpace(5),
                  Text(priere.label,
                      style: TextStyle(fontSize: 15.0, color: fontGreyDark)),
                ],
              )),
          Expanded(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(controller.adjustTimeForParis(priere.time),
                      style: TextStyle(
                          fontSize: 18.0,
                          color: fontDark,
                          fontWeight: FontWeight.w900)),
                  UIHelper.horizontalSpace(15),
                  GestureDetector(
                    onTap: () {
                      controller.savePrayKey(priere);
                    },
                    child: Icon(
                        priere.isNotified
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: priere.isNotified ? fontGreyDark : fontGrey),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget nextPrayTime(PriereController controller) {
    return ValueListenableBuilder<String>(
      builder: (BuildContext context, String nextPrayHour, Widget? child) {
        if (nextPrayHour == '') {
          return Container();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('prochaine prière', style: TextStyle(fontSize: 15.0, color: fontGreyBrown)),
            // UIHelper.verticalSpace(5),
            Row(
              children: [
                Text('${controller.nextPrayName} dans',
                    style: TextStyle(
                        fontSize: 19.0,
                        color: white,
                        fontWeight: FontWeight.w900)),
                UIHelper.horizontalSpace(10),
                Text(nextPrayHour,
                    style: TextStyle(
                        fontSize: 35.0,
                        color: white,
                        fontWeight: FontWeight.w900)),
              ],
            )
          ],
        );
      },
      valueListenable: controller.nextPrayHour,
    );
  }

  __nextPray(PriereController controller) {
    if (controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: UIHelper.lineLoaders(3, 15),
      );
    }
    return controller.needDefineLocation
        ? Container(
            margin:
                const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 12),
            child: Column(
              children: [
                Text(
                    'Pour visualiser les heures de prière merci de préciser votre localisation',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                UIHelper.verticalSpace(8),
                GestureDetector(
                    child: ElevatedButton(
                  onPressed: () {
                    controller.setLocation();
                  },
                  child: Icon(MdiIcons.homeSearch, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Color(0xFFBE914F)),
                )),
              ],
            ))
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () {
                                controller.setLocation();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    UIHelper.horizontalSpace(5),
                                    Text(
                                        "${controller.praytime!.location.city}",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900)),
                                    UIHelper.horizontalSpace(5),
                                  ],
                                ),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${controller.praytime!.date} - ",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.white)),
                              Text("${controller.praytime!.dateMuslim}",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.white)),
                            ],
                          ),
                          UIHelper.verticalSpace(5),
                          Center(child: __nextPrayTime(controller)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget __nextPrayTime(PriereController controller) {
    return ValueListenableBuilder<String>(
      builder: (BuildContext context, String nextPrayHour, Widget? child) {
        if (nextPrayHour == '') {
          return Container();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${controller.nextPrayName} dans',
                style: TextStyle(
                    fontSize: 17.0, color: white, fontWeight: FontWeight.w900)),
            UIHelper.verticalSpace(5),
            Text(nextPrayHour,
                style: TextStyle(
                    fontSize: 33.0, color: white, fontWeight: FontWeight.w900)),
          ],
        );
      },
      valueListenable: controller.nextPrayHour,
    );
  }
}

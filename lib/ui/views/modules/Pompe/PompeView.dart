import 'package:elh/models/pompe.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Pompe/PompeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class PompeView extends StatefulWidget {
  @override
  PompeViewState createState() => PompeViewState();
}

class PompeViewState extends State<PompeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PompeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Pompes funèbres', style: headerTextWhite),
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    elevation: 3,
                    offset: Offset(30, 35),
                    child: Icon(
                      MdiIcons.plus,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext bc) => menuItems(controller),
                    onCanceled: () {},
                    onSelected: (value) {
                      if (value == 'addPompe') {
                        controller.addPompe();
                      } else if (value == 'pompeDemands') {
                        controller.viewDemands();
                      }
                    },
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1),
                      Color.fromRGBO(143, 151, 121, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: bgLightV2,
                    padding: EdgeInsets.only(
                        bottom: 20, top: 20, left: 20, right: 20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            TextFormField(
                              controller: controller.cityTextController,
                              onTap: () {
                                controller.openSearchLocation(context);
                              },
                              readOnly: true,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: bgGrey, width: 1),
                                      borderRadius: BorderRadius.circular(30)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(color: bgGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(color: bgGrey),
                                  ),
                                  filled: true,
                                  fillColor: white,
                                  labelText: "À proximité de ..."),
                            ),
                            Positioned(
                              right: 14,
                              top: 5,
                              child: Container(
                                color: Colors.white,
                                child: DropdownButton<int>(
                                  value: controller.distance,
                                  icon: const Icon(
                                    Icons.arrow_downward,
                                    size: 14,
                                  ),
                                  elevation: 16,
                                  style: const TextStyle(color: fontDark),
                                  underline: Container(height: 0),
                                  onChanged: (int? newDistance) {
                                    controller.setDistance(newDistance);
                                  },
                                  items:
                                      controller.distances.map((int distance) {
                                    return DropdownMenuItem<int>(
                                      value: distance,
                                      child: Text("${distance}km"),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: controller.isLoading
                          ? Center(child: BBloader())
                          : ListView(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              children: [
                                Column(
                                  children: pompes(controller),
                                ),
                                controller.isPompeOwner
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          UIHelper.verticalSpace(20),
                                          Text(
                                            'Gestionnaire de pompes funèbres',
                                            style: labelSmallStyle,
                                          ),
                                          UIHelper.verticalSpace(10),
                                          Column(
                                            children:
                                                pompes(controller, own: true),
                                          )
                                        ],
                                      )
                                    : Container()
                              ],
                            )),
                ],
              ),
            )),
        viewModelBuilder: () => PompeController());
  }

  List<Widget> pompes(PompeController pompeController, {own = false}) {
    List<Widget> pompeList = [];
    List<Pompe> pompes;
    if (own) {
      pompes = pompeController.ownPompes;
    } else {
      pompes = pompeController.pompes;
    }
    pompes.forEach((Pompe pompe) {
      pompeList.add(ExpansionTile(
        tilePadding: pompe.isExpanded
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 15)
            : EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        collapsedShape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        onExpansionChanged: (bool active) =>
            pompeController.setActivePompe(pompe, active),
        backgroundColor: white,
        collapsedBackgroundColor: white,
        // trailing: Icon(Icons.keyboard_arrow_down_sharp),
        iconColor: Colors.grey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pompe.name,
                style: TextStyle(
                    fontSize: 16.0,
                    color: fontDark,
                    fontWeight: FontWeight.w700,
                    height: 1.4)),
            RichText(
              text: TextSpan(
                  text: pompe.location.label,
                  style: TextStyle(color: fontGreyDark, fontSize: 15),
                  children: [
                    TextSpan(
                        text:
                            pompe.distance > 0 ? " (${pompe.distance}km)" : "",
                        style: TextStyle(color: fontGrey, fontSize: 13))
                  ]),
            ),
          ],
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: HtmlWidget(pompe.description,
                onTapUrl: (url) => pompeController.openUrl(url)),
          ),
          UIHelper.verticalSpace(15),
          own
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pompeController.managePompe(pompe);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10),
                        child: Text('Gérer', style: linkStyleBold),
                      ),
                    )
                  ],
                )
              : Container()
        ],
      ));
      pompeList.add(UIHelper.verticalSpace(10));
    });
    //voir demandes
    if (own && pompeController.ownPompes.length > 0) {
      pompeList.add(GestureDetector(
        onTap: () {
          pompeController.viewDemands();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Voir mes demandes',
                  style: TextStyle(
                      fontSize: 18,
                      color: primaryColor,
                      fontWeight: FontWeight.w700)),
              UIHelper.horizontalSpace(10),
              Icon(Icons.arrow_right_alt_rounded, color: primaryColor, size: 28)
            ],
          ),
        ),
      ));
    }

    return pompeList;
  }

  List<PopupMenuItem> menuItems(PompeController controller) {
    List<PopupMenuItem> itemList = [];
    if (!controller.isPompeOwner) {
      itemList.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.plus),
              UIHelper.horizontalSpace(8),
              Text("Inscrire mes pompes funèbres"),
            ],
          ),
          value: "addPompe"));
    }

    if (controller.isPompeOwner) {
      itemList.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.pencilOutline),
              UIHelper.horizontalSpace(8),
              Text("Gérer mes pompes funèbres"),
            ],
          ),
          value: "addPompe"));
      itemList.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.chatOutline),
              UIHelper.horizontalSpace(8),
              Text("Mes demandes"),
            ],
          ),
          value: "pompeDemands"));
    }
    return itemList;
  }
}

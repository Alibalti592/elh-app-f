import 'package:elh/models/maraude.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Maraude/MaraudeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class MaraudeView extends StatefulWidget {
  @override
  MaraudeViewState createState() => MaraudeViewState();
}

class MaraudeViewState extends State<MaraudeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MaraudeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              title: Text(controller.title, style: headerTextWhite),
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
                      if (value == 'addMaraude') {
                        controller.addMaraude();
                      } else if (value == 'setMyMaraudes') {
                        controller.setMyMaraudes();
                      } else if (value == 'setAllMaraudes') {
                        controller.setAllMaraudes();
                      }
                    },
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1.0),
                      Color.fromRGBO(143, 151, 121, 1.0),
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
                  controller.myMaraudesView
                      ? Container()
                      : Container(
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
                                            borderSide: BorderSide(
                                                color: bgGrey, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0)),
                                          borderSide: BorderSide(color: bgGrey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0)),
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
                                        items: controller.distances
                                            .map((int distance) {
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
                                  vertical: 10, horizontal: 10),
                              children: maraudes(controller),
                            ))
                ],
              ),
            )),
        viewModelBuilder: () => MaraudeController());
  }

  List<Widget> maraudes(MaraudeController maraudeController) {
    List<Widget> maraudeList = [];
    maraudeController.maraudes.forEach((Maraude maraude) {
      maraudeList.add(ExpansionTile(
        tilePadding: maraude.isExpanded
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 15)
            : EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        collapsedShape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        onExpansionChanged: (bool active) =>
            maraudeController.setActiveMaraude(maraude, active),
        backgroundColor: white,
        collapsedBackgroundColor: white,
        // trailing: Icon(Icons.keyboard_arrow_down_sharp),
        iconColor: Colors.grey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(maraude.dateDisplay!,
                style: TextStyle(
                    fontSize: 16.0,
                    color: fontDark,
                    fontWeight: FontWeight.w700,
                    height: 1.4)),
            Text(maraude.timeDisplay!,
                style: TextStyle(fontSize: 15.0, color: fontDark)),
            RichText(
              text: TextSpan(
                  text: maraude.location!.label,
                  style: TextStyle(color: fontGreyDark, fontSize: 15),
                  children: [
                    TextSpan(
                        text: maraude.distance > 0
                            ? " (${maraude.distance}km)"
                            : "",
                        style: TextStyle(color: fontGrey, fontSize: 13))
                  ]),
            ),
          ],
        ),
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            alignment: Alignment.topLeft,
            child: HtmlWidget(maraude.description,
                onTapUrl: (url) => maraudeController.openUrl(url)),
          ),
          UIHelper.verticalSpace(15)
        ],
      ));
      maraudeList.add(UIHelper.verticalSpace(10));
    });
    return maraudeList;
  }

  List<PopupMenuItem> menuItems(MaraudeController controller) {
    List<PopupMenuItem> itemList = [];
    itemList.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.plus),
            UIHelper.horizontalSpace(8),
            Text("Ajouter une maraude"),
          ],
        ),
        value: "addMaraude"));
    if (controller.myMaraudesView) {
      itemList.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.mapMarkerOutline),
              UIHelper.horizontalSpace(8),
              Text("Maraudes à proximité"),
            ],
          ),
          value: "setAllMaraudes"));
    } else {
      itemList.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.formatListChecks),
              UIHelper.horizontalSpace(8),
              Text("Mes maraudes"),
            ],
          ),
          value: "setMyMaraudes"));
    }

    return itemList;
  }
}

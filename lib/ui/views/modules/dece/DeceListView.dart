import 'package:elh/common/theme.dart';
import 'package:elh/models/imam.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/dece/DeceListController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class DeceListView extends StatefulWidget {
  DeceListView();
  @override
  DeceListViewState createState() => DeceListViewState();
}

class DeceListViewState extends State<DeceListView> {
  DeceListViewState();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeceListController>.reactive(
        viewModelBuilder: () => DeceListController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
                elevation: 0,
                iconTheme: new IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent,
                title: Text("Contacter des pompes funèbres",
                    style: headerTextWhite),
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: PopupMenuButton(
                      elevation: 3,
                      offset: Offset(30, 35),
                      child: Icon(MdiIcons.plus, color: Colors.white),
                      itemBuilder: (BuildContext bc) => [
                        PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(MdiIcons.plus),
                                UIHelper.horizontalSpace(5),
                                Text(
                                  "Contacter des pompes funèbres",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            value: "addDeces"),
                      ],
                      onCanceled: () {},
                      onSelected: (value) {
                        if (value == 'addDeces') {
                          controller.addDeces();
                        }
                      },
                    ),
                  ),
                ]),
            extendBody: true,
            body: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: controller.isLoading
                    ? BBloader()
                    : RefreshIndicator(
                        onRefresh: controller.loadDatas,
                        child: ListView(children: _listDeces(controller))),
                // DefaultTabController(
                //       initialIndex: controller.tabIndex,
                //       length: 3,
                //       child: Column(
                //         children: <Widget>[
                //           // ButtonsTabBar(
                //           //   backgroundColor: primaryColor,
                //           //   radius: 10,
                //           //   contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                //           //   unselectedBackgroundColor: Colors.white,
                //           //   unselectedLabelStyle: TextStyle(color: fontGreyLight),
                //           //   labelStyle: TextStyle(
                //           //       color: Colors.white,
                //           //       fontWeight: FontWeight.bold),
                //           //   tabs: [
                //           //     Tab(
                //           //       text: "Décès annoncés",
                //           //     ),
                //           //     Tab(
                //           //       text: "Demandes de pardon",
                //           //     ),
                //           //     Tab(text: "Trouver un imam"),
                //           //   ],
                //           // ),
                //           // Expanded(
                //           //   child: TabBarView(
                //           //     children: <Widget>[
                //           //
                //           //     RefreshIndicator(
                //           //         onRefresh: controller.loadDatas,
                //           //         child: ListView(
                //           //             children: _listPardons(controller)
                //           //     )),
                //           //     Column(
                //           //         children: [
                //           //           searchImams(controller),
                //           //           imamsList(controller),
                //           //         ],
                //           //       )
                //           //     ],
                //           //   ),
                //           // ),
                //         ],
                //       ),
                //     ),
              ),
            )));
  }

  List<Widget> _listDeces(DeceListController controller) {
    List<Widget> widgets = [];
    if (controller.deces.isEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Center(child: Text('Aucun décès déclaré')),
      ));
    } else {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 20),
      ));
      controller.deces.forEach((dece) {
        widgets.add(Hero(
          tag: "dece-car-${dece.id}",
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
                onTap: () {
                  controller.goToDece(dece);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                tileColor: Colors.white,
                title: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${dece.firstname} ${dece.lastname}",
                            style: headerText),
                        UIHelper.verticalSpace(3),
                        Text("Décèdé le ${dece.dateDisplay}", style: smallText),
                        UIHelper.verticalSpace(5),
                        Text("Tes contacts avec les pompes funèbres : 0",
                            style: smallText),
                      ],
                    ),
                  ),
                ),
                trailing: Icon(MdiIcons.arrowRight)),
          ),
        ));
        widgets.add(UIHelper.verticalSpace(15));
      });
    }
    return widgets;
  }

  List<Widget> _listPardons(DeceListController controller) {
    List<Widget> widgets = [];
    if (controller.pardons.isNotEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Text('Demande de pardon envoyé', style: labelSmallStyle),
      ));
      controller.pardons.forEach((pardon) {
        widgets.add(pardonTile(pardon, controller));
        widgets.add(UIHelper.verticalSpace(15));
      });
    }
    if (controller.sharedPardons.isNotEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Text('Demande de pardon reçu', style: labelSmallStyle),
      ));
      controller.sharedPardons.forEach((pardon) {
        widgets.add(pardonTile(pardon, controller));
        widgets.add(UIHelper.verticalSpace(15));
      });
    }
    return widgets;
  }

  Widget pardonTile(pardon, controller) {
    return ListTile(
      onTap: () {
        //show details
        controller.expandPardon(pardon);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      tileColor: Colors.white,
      title: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${pardon.firstname} ${pardon.lastname}", style: headerText),
              pardon.isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          Text(pardon.content, style: TextStyle(fontSize: 13)),
                    )
                  : Container()
            ],
          ),
        ),
      ),
      trailing: pardon.canEdit
          ? PopupMenuButton(
              elevation: 3,
              offset: Offset(30, 35),
              child: Icon(MdiIcons.plus),
              itemBuilder: (BuildContext bc) => [
                PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(MdiIcons.pencilOutline),
                        UIHelper.horizontalSpace(8),
                        Text("Modifier"),
                      ],
                    ),
                    value: "editPardon"),
              ],
              onCanceled: () {},
              onSelected: (val) {
                if (val == 'editPardon') {
                  controller.editPardon(pardon);
                }
              },
            )
          : null,
    );
  }

  Widget searchImams(DeceListController controller) {
    return Column(
      children: [
        UIHelper.verticalSpace(15),
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
                      borderSide: BorderSide(color: bgGrey, width: 1),
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: bgGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
                  items: controller.distances.map((int distance) {
                    return DropdownMenuItem<int>(
                      value: distance,
                      child: Text("${distance}km"),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
        UIHelper.verticalSpace(20)
      ],
    );
  }

  Widget imamsList(DeceListController controller) {
    List<Widget> imamCards = [];
    controller.imams.forEach((imam) {
      imamCards.add(Container(
          margin: const EdgeInsets.only(top: 10),
          child: _imam(controller, imam)));
    });
    // imamCards.add(value);
    return Expanded(
      child: RefreshIndicator(
          onRefresh: controller.loadImams,
          child: ListView(children: imamCards)),
    );
  }

  Widget _imam(DeceListController controller, Imam imam) {
    Widget tileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(imam.name,
            style: TextStyle(
                fontSize: 16.0,
                color: fontDark,
                fontWeight: FontWeight.w700,
                height: 1.4)),
        RichText(
          text: TextSpan(
              text: imam.location.label,
              style: TextStyle(color: fontGreyDark, fontSize: 15),
              children: [
                TextSpan(
                    text: imam.distance > 0 ? " (${imam.distance}km)" : "",
                    style: TextStyle(color: fontGrey, fontSize: 13)),
              ]),
        ),
      ],
    );

    return ExpansionTile(
      tilePadding: imam.isExpanded
          ? EdgeInsets.symmetric(vertical: 10, horizontal: 15)
          : EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      collapsedShape: RoundedRectangleBorder(
          side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
      shape: RoundedRectangleBorder(
          side: BorderSide.none, borderRadius: BorderRadius.circular(10)),
      onExpansionChanged: (bool active) =>
          controller.setActiveImam(imam, active),
      backgroundColor: white,
      collapsedBackgroundColor: white,
      iconColor: Colors.grey,
      title: tileContent,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: HtmlWidget(imam.description,
              onTapUrl: (url) => controller.openUrl(url)),
        ),
        UIHelper.verticalSpace(15)
      ],
    );
  }
}

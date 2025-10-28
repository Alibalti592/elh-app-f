import 'package:elh/models/pompe.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Pompe/MyPompeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class MyPompeView extends StatefulWidget {
  @override
  MyPompeViewState createState() => MyPompeViewState();
}

class MyPompeViewState extends State<MyPompeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyPompeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Mes Pompes funèbres', style: headerTextWhite),
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
              child: controller.isLoading
                  ? BBloader()
                  : RefreshIndicator(
                      onRefresh: controller.refreshData,
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        children: [
                          controller.isPompeOwner
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: pompes(controller),
                                    )
                                  ],
                                )
                              : Container(
                                  child: Text(
                                      "Tu n'as pas de pompe funèbre enregistrée !"))
                        ],
                      ),
                    ),
            )),
        viewModelBuilder: () => MyPompeController());
  }

  List<Widget> pompes(MyPompeController pompeController) {
    List<Widget> pompeList = [];
    List<Pompe> pompes = pompeController.ownPompes;

    pompeList.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          pompeController.viewDemands();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: primaryColor, borderRadius: BorderRadius.circular(20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Voir mes demandes',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              UIHelper.horizontalSpace(10),
              Icon(Icons.arrow_right_alt_rounded, color: Colors.white, size: 28)
            ],
          ),
        ),
      ),
    ));

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
                    fontSize: 17.0,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Statut", style: labelSmallStyle),
                Text(pompeController.getStatusLabel(pompe),
                    style: TextStyle(
                        color: fontGreyDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nom du responsable", style: labelSmallStyle),
                Text(pompe.namePro,
                    style: TextStyle(
                        color: fontDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Téléphone", style: labelSmallStyle),
                Text("${pompe.phonePrefix} ${pompe.phone}",
                    style: TextStyle(
                        color: fontDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: HtmlWidget(pompe.description,
                onTapUrl: (url) => pompeController.openUrl(url)),
          ),
          UIHelper.verticalSpace(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  pompeController.managePompe(pompe);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  child: Text('Modifier', style: linkStyleBold),
                ),
              )
            ],
          )
        ],
      ));
      pompeList.add(UIHelper.verticalSpace(10));
    });

    return pompeList;
  }

  List<PopupMenuItem> menuItems(MyPompeController controller) {
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
              Icon(MdiIcons.plusCircleOutline),
              UIHelper.horizontalSpace(8),
              Text("Ajouter mes pompes funèbres"),
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

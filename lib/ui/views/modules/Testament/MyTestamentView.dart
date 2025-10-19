import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCard.dart';
import 'package:elh/ui/views/modules/Testament/MyTestamentController.dart';
import 'package:elh/ui/views/modules/Testament/_TestamentWidget.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class MyTestamentView extends StatefulWidget {
  @override
  MyTestamentViewState createState() => MyTestamentViewState();
}

class MyTestamentViewState extends State<MyTestamentView> {
  MyTestamentViewState();

  @override
  Widget build(BuildContext context) {
    final double minContentHeight = MediaQuery.of(context).size.height - 50;

    return ViewModelBuilder<MyTestamentController>.reactive(
        viewModelBuilder: () => MyTestamentController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Mon Testament", style: headerTextWhite),
              actions: [
                controller.pdfLoading ? BBloader() : Container(),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    elevation: 3,
                    offset: Offset(30, 35),
                    child: Icon(MdiIcons.dotsVertical, color: Colors.white),
                    itemBuilder: (BuildContext bc) => [
                      PopupMenuItem(
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Aligner en haut
                          children: [
                            Icon(MdiIcons.keyOutline),
                            UIHelper.horizontalSpace(8),
                            Expanded(
                              // Permet au texte de prendre l'espace restant
                              child: Text(
                                "Donner l’accès privé à mes proches",
                                style: TextStyle(fontSize: 14),
                                maxLines: 2, // Permet de découper sur 2 lignes
                                overflow: TextOverflow
                                    .ellipsis, // Ajoute des points de suspension si nécessaire
                                softWrap: true, // Permet le retour à la ligne
                              ),
                            ),
                          ],
                        ),
                        value: "shareTestament",
                      ),
                      PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(MdiIcons.shareVariantOutline),
                              UIHelper.horizontalSpace(8),
                              Text("Envoyer mon testament",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          value: "downloadTestament")
                    ],
                    onCanceled: () {},
                    onSelected: (value) {
                      if (value == 'editTestament') {
                        controller.editTestament();
                      } else if (value == 'shareTestament') {
                        controller.shareTestament();
                      } else if (value == 'downloadTestament') {
                        controller.exportAsPdf();
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
            extendBody: true,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: primaryColor,
              onPressed: () {
                controller.editTestament();
              },
              label: const Text(
                'Rédiger mon testament',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon: Icon(MdiIcons.pencilOutline, color: Colors.white, size: 25),
            ),
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                    onRefresh: controller.refreshDatas,
                    child: SingleChildScrollView(
                      child: RepaintBoundary(
                        key: controller.globalKey,
                        child: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: minContentHeight,
                          ),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: controller.testament == null
                                  ? BBloader()
                                  : Column(
                                      children: [
                                        TestamentWidget(
                                            controller.testament!,
                                            controller.jeds,
                                            controller.onms,
                                            controller.amanas,
                                            controller.joursJeun),
                                        // Column(
                                        //   children: listObligations(controller),
                                        // )
                                      ],
                                    )),
                        ),
                      ),
                    ),
                  ))));
  }

  List<Widget> listObligations(MyTestamentController controller) {
    bool isAShare = false;
    List<Widget> obligationWigets = [];
    if (controller.obligations.isEmpty) {
      String text = "Aucune dette enregistrée";
      obligationWigets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Center(child: Text(text)),
      ));
    } else {
      controller.obligations.forEach((obligation) {
        obligationWigets.add(_obligation(controller, obligation, isAShare));
      });
    }
    return obligationWigets;
  }

  Widget _obligation(
      MyTestamentController controller, Obligation obligation, isAShare) {
    List<PopupMenuItem> menuItems = [];
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.check),
            UIHelper.horizontalSpace(8),
            Text("Marquer comme remboursé"),
          ],
        ),
        value: "refundObligation"));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Hero(
        tag: "obligation-tag-${obligation.id}",
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) => Center(
                      child: ObligationCard(
                          obligation: obligation, directShare: false),
                    ),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              tileColor: Colors.white,
              title: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${obligation.firstname} ${obligation.lastname}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Karla')),
                      UIHelper.verticalSpace(2),
                      obligation.type != 'amana'
                          ? Text("Montant :  ${obligation.amount} €",
                              style:
                                  TextStyle(color: fontGreyDark, fontSize: 12))
                          : Container(),
                      UIHelper.verticalSpace(2),
                      Text("Date : ${obligation.dateDisplay}",
                          style: TextStyle(color: fontGreyDark, fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

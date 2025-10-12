import 'package:elh/common/theme.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Carte/CarteCard.dart';
import 'package:elh/ui/views/modules/Carte/CarteListController.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class CarteListView extends StatefulWidget {
  final Carte? openCarte;
  String onglet = 'create';
  CarteListView({this.openCarte, this.onglet = 'create'});
  @override
  CarteListViewState createState() =>
      CarteListViewState(this.openCarte, this.onglet);
}

class CarteListViewState extends State<CarteListView> {
  final Carte? openCarte;
  String onglet = 'create';
  CarteListViewState(this.openCarte, this.onglet);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarteListController>.reactive(
        viewModelBuilder: () =>
            CarteListController(context, this.openCarte, this.onglet),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              title: Text("Cartes virtuelles de circonstances",
                  style: headerTextWhite),
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
                    itemBuilder: (BuildContext bc) => [
                      PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(MdiIcons.plus),
                              UIHelper.horizontalSpace(8),
                              Text("Créer une carte virtuelle"),
                            ],
                          ),
                          value: "addCartes"),
                    ],
                    onCanceled: () {},
                    onSelected: (value) {
                      if (value == 'addCartes') {
                        controller.addCartes();
                      }
                    },
                  ),
                ),
              ],
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
            extendBody: true,
            body: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: controller.isLoading
                    ? BBloader()
                    : Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.setTabEnLoadDatas(0);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      "Cartes créées",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller.filter == 'create'
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  ),
                                ),
                                UIHelper.horizontalSpace(5),
                                GestureDetector(
                                  onTap: () {
                                    controller.setTabEnLoadDatas(1);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      "Cartes envoyées",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller.filter == 'send'
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  ),
                                ),
                                UIHelper.horizontalSpace(5),
                                GestureDetector(
                                  onTap: () {
                                    controller.setTabEnLoadDatas(2);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 15),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      "Cartes reçues",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller.filter == 'receive'
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          UIHelper.verticalSpace(15),
                          Expanded(
                              child: RefreshIndicator(
                            onRefresh: controller.loadDatas,
                            child: ListView(children: _listCartes(controller)),
                          ))
                        ],
                      ),
              ),
            )));
  }

  List<Widget> _listCartes(CarteListController controller) {
    List<Widget> widgets = [];
    if (controller.filter == 'receive') {
      if (controller.carteShares.isEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Center(child: Text('Aucune carte reçue')),
        ));
      } else {
        int loop = 0;
        controller.carteShares.forEach((carte) {
          widgets.add(_carte(controller, carte, true));
          widgets.add(UIHelper.verticalSpace(15));
          loop++;
        });
      }
    } else {
      if (controller.cartes.isEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Center(
              child: Text(controller.filter == 'send'
                  ? 'Aucune carte envoyée'
                  : 'Aucune carte ajoutée')),
        ));
      } else {
        int loop = 0;
        controller.cartes.forEach((carte) {
          widgets.add(_carte(controller, carte, false));
          widgets.add(UIHelper.verticalSpace(15));
          loop++;
        });
      }
    }

    return widgets;
  }

  Widget _carte(CarteListController controller, Carte carte, isShared) {
    List<PopupMenuItem> menuItems = [];
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.shareVariantOutline),
            UIHelper.horizontalSpace(8),
            Text("Partager à ma communauté"),
          ],
        ),
        value: "shareCarte"));
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.shareAllOutline),
            UIHelper.horizontalSpace(8),
            Text("Partager à mes contacts"),
          ],
        ),
        value: "shareCarteWhatsap"));

    if (!carte.canEdit && isShared) {
      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.trashCanOutline),
              UIHelper.horizontalSpace(8),
              Text("Supprimer"),
            ],
          ),
          value: "deleteShareCarte"));
    }

    if (carte.canEdit) {
      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.pencilOutline),
              UIHelper.horizontalSpace(8),
              Text("Modifier"),
            ],
          ),
          value: "editCarte"));
      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.trashCanOutline),
              UIHelper.horizontalSpace(8),
              Text("Supprimer"),
            ],
          ),
          value: "deleteCarte"));
    }

    return Hero(
      tag: "carte-tag-${carte.id}",
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (context) => Center(
                  child: (carte.type == 'salat' && carte.salat != null)
                      ? SalatCard(salat: carte.salat!)
                      : CarteCard(carte: carte),
                ),
              ),
            );
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
                  Text("${carte.typeLabel}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Karla')),
                  UIHelper.verticalSpace(2),
                  Text("${carte.title}",
                      style: TextStyle(color: fontGreyDark, fontSize: 12)),
                ],
              ),
            ),
          ),
          trailing: PopupMenuButton(
            elevation: 3,
            offset: Offset(30, 35),
            child: Icon(MdiIcons.dotsVerticalCircleOutline),
            itemBuilder: (BuildContext bc) => menuItems,
            onCanceled: () {},
            onSelected: (val) {
              if (val == 'editCarte') {
                controller.editCarte(carte);
              } else if (val == 'shareCarte') {
                controller.shareCarte(carte);
              } else if (val == 'shareCarteWhatsap') {
                controller.shareCarteWhatsap(carte);
              } else if (val == 'deleteCarte') {
                controller.deleteCarte(carte);
              } else if (val == 'deleteShareCarte') {
                controller.deleteShareCarte(carte);
              }
            },
          ),
        ),
      ),
    );
  }
}

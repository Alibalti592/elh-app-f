import 'package:elh/common/theme.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:elh/ui/views/modules/Salat/SalatListController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class SalatListView extends StatefulWidget {
  SalatListView();
  @override
  SalatListViewState createState() => SalatListViewState();
}

class SalatListViewState extends State<SalatListView> {
  SalatListViewState();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalatListController>.reactive(
        viewModelBuilder: () => SalatListController(context),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Salât Al-Janaza", style: headerTextWhite),
              actions: [],
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
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: primaryColor,
              onPressed: () {
                controller.addSalats();
              },
              label: const Text(
                'Ajouter une Salât Al-Janaza',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 25),
            ),
            extendBody: true,
            body: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: controller.isLoading
                    ? BBloader()
                    : RefreshIndicator(
                        onRefresh: controller.loadDatas,
                        child: ListView(children: _listSalats(controller)),
                      ),
              ),
            )));
  }

  List<Widget> _listSalats(SalatListController controller) {
    List<Widget> widgets = [];
    widgets.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text('Publications des Salâts Al-Janaza', style: labelSmallStyle),
    ));
    if (controller.salatsOfMosque.isEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Center(
            child: Text(
          "Aucune Salât Al-Janaza annoncée. Pour recevoir les alertes de Salât al-Janaza d'une mosquée, ajoutez la mosquée en favoris",
          textAlign: TextAlign.center,
        )),
      ));
    } else {
      controller.salatsOfMosque.forEach((salat) {
        widgets.add(_salat(controller, salat));
        widgets.add(UIHelper.verticalSpace(15));
      });
    }
    widgets.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text('Mes Salâts Al-Janaza ajoutées', style: labelSmallStyle),
    ));
    if (controller.salats.isEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Center(child: Text('Aucune Salât Al-Janaza ajoutée')),
      ));
    } else {
      int loop = 0;
      controller.salats.forEach((salat) {
        widgets.add(_salat(controller, salat));
        widgets.add(UIHelper.verticalSpace(15));
        loop++;
      });
    }
    return widgets;
  }

  Widget _salat(SalatListController controller, Salat salat) {
    List<PopupMenuItem> menuItems = [];
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.shareOutline),
            UIHelper.horizontalSpace(8),
            Text("Partager"),
          ],
        ),
        value: "shareSalat"));

    if (salat.canEdit) {
      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.listBox),
              UIHelper.horizontalSpace(8),
              Text("Modifier"),
            ],
          ),
          value: "editSalat"));

      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.trashCanOutline),
              UIHelper.horizontalSpace(8),
              Text("Supprimer"),
            ],
          ),
          value: "deleteSalat"));
    }

    return Hero(
      tag: "salat-tag-${salat.id}",
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (context) => Center(
                  child: SalatCard(salat: salat),
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
                  Text("${salat.firstname} ${salat.lastname}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: fontDark,
                          fontFamily: 'Karla')),
                  UIHelper.verticalSpace(5),
                  salat.mosque != null
                      ? Text("Mosquée : ${salat.mosque!.name}",
                          style: TextStyle(color: fontGreyDark, fontSize: 12))
                      : Container(),
                  UIHelper.verticalSpace(2),
                  Text("Le ${salat.dateDisplay}",
                      style: TextStyle(color: fontGreyDark, fontSize: 12)),
                ],
              ),
            ),
          ),
          trailing: PopupMenuButton(
            elevation: 3,
            offset: Offset(30, 35),
            child: Icon(Icons.app_registration_rounded),
            itemBuilder: (BuildContext bc) => menuItems,
            onCanceled: () {},
            onSelected: (val) {
              if (val == 'editSalat') {
                controller.editSalat(salat);
              } else if (val == 'shareSalat') {
                controller.shareSalat(salat);
              } else if (val == 'deleteSalat') {
                controller.deleteSalat(salat);
              }
            },
          ),
        ),
      ),
    );
  }
}

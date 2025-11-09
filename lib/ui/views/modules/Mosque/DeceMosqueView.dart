import 'package:elh/models/MosqueDece.dart';
import 'package:elh/models/mosque.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Mosque/DeceMosqueController.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class DeceMosqueView extends StatefulWidget {
  Mosque mosque;
  DeceMosqueView(this.mosque);

  @override
  DeceMosqueViewState createState() => DeceMosqueViewState(this.mosque);
}

class DeceMosqueViewState extends State<DeceMosqueView> {
  Mosque mosque;
  DeceMosqueViewState(this.mosque);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeceMosqueController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Décès annoncés', style: headerText),
              backgroundColor: Colors.transparent,
              actions: [],
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
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                    child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        controller: controller.scrollController,
                        children: decesMosque(controller)),
                    onRefresh: controller.refreshData,
                  ))),
        viewModelBuilder: () => DeceMosqueController(this.mosque));
  }

  List<Widget> decesMosque(DeceMosqueController controller) {
    List<Widget> demands = [];
    controller.salats.forEach((salat) {
      demands.add(_salat(controller, salat));
      demands.add(UIHelper.verticalSpace(15));
    });
    if (demands.length == 0) {
      demands.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Center(
            child: Text(
          'Aucune Salât Al-Janaza \n anoncée pour cette Mosquée',
          style: noResultStyle,
          textAlign: TextAlign.center,
        )),
      ));
    }
    demands.add(Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Center(
          child: Text(
              "Pour recevoir les notifications des publications des Salât Al-Janaza d'une mosquée, ajoutes-la en FAVORIS.",
              style: noResultStyleDark,
              textAlign: TextAlign.center)),
    ));

    return demands;
  }

  Widget _salat(DeceMosqueController controller, Salat salat) {
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
              if (val == 'shareSalat') {
                controller.shareSalat(salat);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget dmWidget(DeceMosqueController controller, DeceMosque dm) {
    return Card(
        elevation: 1,
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Annoncé le ${dm.dateString}',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
              UIHelper.verticalSpace(5),
              Text('Décès de ${dm.dece.firstname} ${dm.dece.lastname}',
                  style: textDescription),
              UIHelper.verticalSpace(10),
              //for show on page if asked
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     ValueListenableBuilder<bool>(
              //       builder: (BuildContext context, bool isSending, Widget? child) {
              //         return isSending ? BBloader() :  Center(
              //             child: GestureDetector(
              //               child: Row(
              //                 children: [
              //                   Text(demand.statusLabel, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              //                   UIHelper.horizontalSpace(5),
              //                   demand.status != 'rejected' ? Icon(ElhIcons.send, size: 20, color: fontGrey) : Container()
              //                 ],
              //               ),
              //               onTap: () {
              //                 if(demand.status == 'canDemand') {
              //                   controller.pompeAcceptDemand(demand);
              //                 }
              //               },
              //             )
              //         );
              //       },
              //       valueListenable: controller.isSending,
              //     ),
              //   ],
              // )
            ],
          ),
        ));
  }
}

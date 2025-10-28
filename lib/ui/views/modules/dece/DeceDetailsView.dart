import 'package:elh/common/theme.dart';
import 'package:elh/models/PompeDemand.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/dece/DeceDetailsController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class DeceDetailsView extends StatefulWidget {
  final Dece dece;
  DeceDetailsView(this.dece);
  @override
  DeceDetailsViewState createState() => DeceDetailsViewState(this.dece);
}

class DeceDetailsViewState extends State<DeceDetailsView> {
  final Dece dece;
  DeceDetailsViewState(this.dece);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeceDetailsController>.reactive(
        viewModelBuilder: () => DeceDetailsController(this.dece),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
                elevation: 0,
                iconTheme: new IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent,
                title: Text("Décès - Pompe funèbre", style: headerTextWhite),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
                                Icon(MdiIcons.pencilOutline),
                                UIHelper.horizontalSpace(8),
                                Text("Modifier le décès"),
                              ],
                            ),
                            value: "editDece"),
                        PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(MdiIcons.trashCanOutline),
                                UIHelper.horizontalSpace(8),
                                Text("Supprimer le décès"),
                              ],
                            ),
                            value: "deleteDece"),
                      ],
                      onCanceled: () {},
                      onSelected: (val) {
                        if (val == 'editDece') {
                          controller.editDece(dece);
                        } else if (val == 'deleteDece') {
                          controller.deleteDece(dece);
                        }
                      },
                    ),
                  ),
                ]),
            extendBody: true,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ListView(
                children: [
                  Text('Décès déclaré', style: labelSmallStyle),
                  UIHelper.verticalSpace(10),
                  SizedBox(
                    child: _deceDetails(dece),
                  ),
                  UIHelper.verticalSpace(20),
                  Text('Pompes funèbres', style: labelSmallStyle),
                  UIHelper.verticalSpace(10),
                  __pfs(controller)
                ],
              ),
            )));
  }

  __pfs(DeceDetailsController controller) {
    if (controller.dece.notifPf == false) {
      return controller.isnotifying
          ? BBloader()
          : GestureDetector(
              onTap: () {
                controller.notifyPF();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Notifier les pompes funèbres aux alentours",
                      style: TextStyle(fontSize: 14, color: white),
                    ),
                  ],
                ),
              ),
            );
    } else {
      if (controller.isLoading) {
        return BBloader();
      } else {
        return Column(
          children: demands(controller),
        );
      }
    }
  }

  List<Widget> demands(DeceDetailsController controller) {
    List<Widget> demands = [];
    if (controller.demands.length == 0) {
      demands.add(Text("Tu as notifié les pompes funèbres aux alentours",
          style: TextStyle(fontSize: 14, color: fontGreyLight),
          textAlign: TextAlign.center));
    }
    controller.demands.forEach((demand) {
      demands.add(demandWidget(controller, demand));
    });
    return demands;
  }

  Widget demandWidget(DeceDetailsController controller, PompeDemand demand) {
    Color color = Color(0xFF1198EF);
    if (demand.status == 'accepted') {
      color = Color(0xFF72A17E);
    } else if (demand.status == 'rejected') {
      color = Color(0xFFEA3232);
    }
    return Card(
        elevation: 1,
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  child: Text('Pompe funèbre : ${demand.pompe.name}',
                      style: inTitleStyle)),
              UIHelper.verticalSpace(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(demand.statusLabel,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: color)),
                  demand.status == 'accepted'
                      ? Text("Tu peux échanger depuis la messagerie")
                      : Container()
                ],
              )
            ],
          ),
        ));
  }

  _deceDetails(Dece dece) {
    return Column(
      children: [
        __cardInfos(MdiIcons.accountOutline, "Défunt",
            "${dece.firstname} ${dece.lastname}"),
        UIHelper.verticalSpace(5),
        __cardInfos(MdiIcons.calendarOutline, "Décèdé le", dece.dateDisplay),
        UIHelper.verticalSpace(5),
        __cardInfos(Icons.pin_drop_outlined, "Lieu du décès",
            "${dece.lieuLabel}  : ${dece.adress?.label}"),
        UIHelper.verticalSpace(5),
        __cardInfos(
            MdiIcons.phoneOutline, "Téléphone pour être contacté", dece.phone),
      ],
    );
  }

  __cardInfos(icon, titre, label) {
    return ConstrainedBox(
      constraints: new BoxConstraints(maxHeight: 50.0, minHeight: 10),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: Row(
          children: [
            Icon(icon),
            UIHelper.horizontalSpace(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: TextStyle(color: fontGrey)),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

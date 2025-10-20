import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Dette/DetteController.dart';
import 'package:elh/ui/views/modules/Dette/ObligationView.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class DetteView extends StatefulWidget {
  final String detteType;
  String tab = 'processing';
  DetteView(this.detteType, {this.tab = 'processing'});
  @override
  DetteViewState createState() => DetteViewState(this.detteType, tab: this.tab);
}

class DetteViewState extends State<DetteView> {
  final String detteType;
  String tab = 'processing';
  DetteViewState(this.detteType, {this.tab = 'processing'});
  String getTitle(String type) {
    if (type == 'jed') {
      return "On me doit";
    } else if (type == 'onm') {
      return "Je dois";
    } else if (type == 'amana') {
      return "Mes Amanas";
    } else {
      return "Mes Obligations"; // fallback title
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetteController>.reactive(
      viewModelBuilder: () => DetteController(this.detteType, this.tab),
      builder: (context, controller, child) => SafeArea(
        child: Scaffold(
          backgroundColor: white,
          extendBody: true,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
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
            title: Text(
              getTitle(this
                  .detteType), // use this.detteType instead of undefined 'type'
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              UIHelper.verticalSpace(15),

              // ===== Toggle Pill Tabs =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Material(
                  elevation: 3, // add shadow
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 57,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // En cours
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.setTabEnLoadDatas(0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.filter == 'processing'
                                    ? Color.fromRGBO(143, 151, 121, 1)
                                    : Colors.white,
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(8),
                                    right: Radius.circular(0)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'En cours',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: controller.filter == 'processing'
                                      ? Colors.white
                                      : Color.fromRGBO(143, 151, 121, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Clôturés
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.setTabEnLoadDatas(1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.filter == 'refund'
                                    ? Color.fromRGBO(143, 151, 121, 1)
                                    : Colors.white,
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(0),
                                    right: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Remboursé(s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: controller.filter == 'refund'
                                      ? Colors.white
                                      : Color.fromRGBO(143, 151, 121, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              UIHelper.verticalSpace(15),

              // ===== Total Amount Card =====
              if (!controller.isLoading && controller.detteType != 'amana')
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Label on the right
                          Text(
                            controller.filter == 'processing'
                                ? 'Total en cours'
                                : 'Total remboursés',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w600),
                          ),
                          // Amount on the left
                          Text(
                            "${controller.totalAmount.toString()} €",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              UIHelper.verticalSpace(10),

              // ===== Obligations List =====
              controller.isLoading
                  ? Expanded(child: Center(child: BBloader()))
                  : Expanded(child: listObligations(controller, detteType)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // same as page padding
                child: SizedBox(
                  width: double.infinity, // full width inside the padding
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(143, 151, 121, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => controller.addObligation(this.detteType),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Ajouter',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Karla',
                      ),
                    ),
                  ),
                ),
              ),
              UIHelper.verticalSpace(20)
            ],
          ),
        ),
      ),
    );
  }

  Widget listObligations(DetteController controller, type) {
    List<Obligation> obligations = [];
    bool isAShare = false;
    if (type == 'jed' || type == 'onm' || type == 'amana') {
      obligations = controller.obligations;
    } else if (type == 'jed-shared' ||
        type == 'onm-shared' ||
        type == 'amana-shared') {
      obligations = controller.obligationsShared;
      isAShare = true;
    }
    List<Widget> obligationWigets = [];
    if (obligations.isEmpty) {
      String text = "Vous n’avez rien prêté pour l’instant";

      if (type == 'amana') {
        text = "Aucune amana enregistrée";
      } else if (type == 'onm') {
        text = "Vous n’avez rien emprunté pour l’instant";
      }
      obligationWigets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Center(
            child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        )),
      ));
    } else {
      obligations.forEach((obligation) {
        obligationWigets.add(_obligation(controller, obligation, isAShare));
      });
      obligationWigets.add(UIHelper.verticalSpace(40));
    }

    return ListView(
      children: obligationWigets,
    );
  }

  Widget _obligation(
      DetteController controller, Obligation obligation, bool isAShare) {
    List<PopupMenuItem> menuItems = [];

    menuItems.add(PopupMenuItem(
      child: Row(
        children: [
          Icon(MdiIcons.download),
          UIHelper.horizontalSpace(8),
          Text("Télécharger"),
        ],
      ),
      value: "download",
    ));

    menuItems.add(PopupMenuItem(
      child: Row(
        children: [
          Icon(obligation.status == 'refund' ? MdiIcons.close : MdiIcons.check),
          UIHelper.horizontalSpace(8),
          Text(obligation.status == 'refund'
              ? "Annuler le remboursement"
              : "Marquer comme remboursé"),
        ],
      ),
      value: "refundObligation",
    ));

    if (!obligation.isRelatedToUser) {
      menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.shareOutline),
            UIHelper.horizontalSpace(8),
            Text("Partager à un membre MC"),
          ],
        ),
        value: "addRelatedTo",
      ));
    }

    if (obligation.canEdit) {
      if (obligation.status != 'refund') {
        menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.pencilOutline),
              UIHelper.horizontalSpace(8),
              Text("Modifier"),
            ],
          ),
          value: "editObligation",
        ));
      }
      menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.trashCanOutline),
            UIHelper.horizontalSpace(8),
            Text("Supprimer"),
          ],
        ),
        value: "deleteObligation",
      ));
    }

    return Hero(
      tag: "obligation-tag-${obligation.id}",
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              HeroDialogRoute(
                // builder: (context) => Center(
                //   child: ObligationCard(
                //     obligation: obligation,
                //     directShare: false,
                //   ),
                // ),
                builder: (context) => ObligationView(
                  obligation: obligation,
                  onTrancheAdded: () async {
                    await controller
                        .loadDatas(); // 👈 reload all obligations/dettes
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obligation.type != 'amana'
                            ? (obligation.type == 'jed'
                                ? obligation.preteurName
                                : obligation.emprunteurName)
                            : obligation.cardOtherName,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Karla'),
                      ),
                      UIHelper.verticalSpace(4),
                      if (obligation.type != 'amana' && obligation.amount != 0)
                        Text(
                            "Montant : ${obligation.amount} ${obligation.currency}",
                            style: TextStyle(
                              color: fontGreyDark,
                              fontSize: 13,
                            )),
                      Text(
                          "Montant restant: ${obligation.remainingAmount} ${obligation.currency}",
                          style: TextStyle(
                            color: fontGreyDark,
                            fontSize: 13,
                          )),
                      UIHelper.verticalSpace(4),
                      if (obligation.type != 'amana')
                        Row(
                          children: [
                            Text(
                                "Date d'échéance : ${obligation.dateStartDisplay}",
                                style: TextStyle(
                                    color: fontGreyDark, fontSize: 11)),
                            UIHelper.horizontalSpace(8),
                            if (controller.isEcheance(obligation))
                              Text("Arrivé à échéance",
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                      if (obligation.isRelatedToUser)
                        Row(
                          children: [
                            Text("Partage membre MC",
                                style: TextStyle(
                                    color: fontGreyDark, fontSize: 11)),
                            UIHelper.horizontalSpace(3),
                            Icon(Icons.check, color: successColor, size: 15)
                          ],
                        ),
                    ],
                  ),
                ),
                // Popup menu
                PopupMenuButton(
                  elevation: 3,
                  offset: Offset(0, 35),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(MdiIcons.dotsVerticalCircleOutline),
                  ),
                  itemBuilder: (BuildContext bc) => menuItems,
                  onSelected: (val) {
                    if (val == 'editObligation') {
                      controller.editObligation(obligation);
                    } else if (val == 'deleteObligation') {
                      controller.deleteObligation(obligation);
                    } else if (val == 'refundObligation') {
                      obligation.status == 'refund'
                          ? controller.cancelRefundObligation(obligation)
                          : controller.refundObligation(obligation);
                    } else if (val == 'download') {
                      controller.openObligationCard(context, obligation, true);
                    } else if (val == 'addRelatedTo') {
                      controller.addRelatedTo(obligation);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

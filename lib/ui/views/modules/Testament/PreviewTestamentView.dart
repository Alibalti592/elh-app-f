import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Testament/PreviewTestamentController.dart';
import 'package:elh/ui/views/modules/Testament/_TestamentWidget.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class PreviewTestamentView extends StatefulWidget {
  Testament testament;
  final List<Obligation> jeds;
  final List<Obligation> onms;
  final List<Obligation> amanas;
  PreviewTestamentView(this.testament, this.jeds, this.onms, this.amanas);
  @override
  PreviewTestamentViewState createState() => PreviewTestamentViewState(
      this.testament, this.jeds, this.onms, this.amanas);
}

class PreviewTestamentViewState extends State<PreviewTestamentView> {
  Testament testament;
  final List<Obligation> jeds;
  final List<Obligation> onms;
  final List<Obligation> amanas;
  PreviewTestamentViewState(this.testament, this.jeds, this.onms, this.amanas);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PreviewTestamentController>.reactive(
        viewModelBuilder: () => PreviewTestamentController(this.testament),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Moi ${testament.from}", style: headerTextWhite),
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
                              Text("Envoyer le testament",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          value: "downloadTestament")
                    ],
                    onCanceled: () {},
                    onSelected: (value) {
                      if (value == 'downloadTestament') {
                        controller.exportAsPdf();
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
            extendBody: true,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: TestamentWidget(testament, this.jeds, this.onms,
                        this.amanas, controller.joursJeun)),
              ),
            )));
  }
}

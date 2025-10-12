import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteSelectTypeController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class AddCarteSelectTypeView extends StatefulWidget {
  @override
  AddCarteSelectTypeViewState createState() => AddCarteSelectTypeViewState();
}

class AddCarteSelectTypeViewState extends State<AddCarteSelectTypeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddCarteSelectTypeController>.reactive(
        viewModelBuilder: () => AddCarteSelectTypeController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              title: Text("Créer une carte virtuelle", style: headerTextWhite),
              actions: [],
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
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                controller.goToList();
              },
              backgroundColor: primaryColor,
              label: const Text(
                'Voir mes cartes virtuelles',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon:
                  Icon(MdiIcons.listBoxOutline, color: Colors.white, size: 25),
            ),
            extendBody: true,
            body: SafeArea(
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1,
                          children: [
                            __navCard(
                                'Annonce d’un décès', controller, 'death'),
                            __navCard(
                                "Invocation  / Doua", controller, 'invocation'),
                            __navCard(
                                "Demande de pardon", controller, 'pardon'),
                            __navCard("Remerciements", controller, 'remercie',
                                fontSize: 14.0),
                            __navCard("Annonce \n Salât Al-Janaza", controller,
                                'salat',
                                fontSize: 15.0),
                            __navCard("Annonce \n Recherche de dettes",
                                controller, 'searchdette',
                                fontSize: 15.0),
                            // __navCard("Salat Janaza", controller, 'salat'),
                          ]),
                    ),
                  )),
            )));
  }

  __navCard(label, controller, type, {double fontSize = 15.0}) {
    const bgWhite = Color(0xffffffff);

    return GestureDetector(
      onTap: () {
        controller.selectType(type);
      },
      child: Material(
        elevation: 4, // Card elevation
        borderRadius: BorderRadius.circular(10),
        color: bgWhite,
        child: Container(
          width: 80,
          height: 80,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Stack(
            children: [
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFf6f6f6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          color: Color.fromRGBO(143, 151, 121, 1),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward,
                        color: Color.fromRGBO(143, 151, 121, 1),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    color: Colors.black,
                    fontFamily: 'Karla',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

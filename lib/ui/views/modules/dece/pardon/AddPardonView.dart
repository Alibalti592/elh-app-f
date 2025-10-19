import 'package:elh/common/theme.dart';
import 'package:elh/models/pardon.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/dece/pardon/AddPardonController.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AddPardonView extends StatefulWidget {
  Pardon? pardon;

  AddPardonView({pardon}) {
    this.pardon = pardon;
  }

  @override
  PardonViewState createState() => PardonViewState(pardon: this.pardon);
}

class PardonViewState extends State<AddPardonView> {
  Pardon? pardon;
  PardonViewState({pardon}) {
    this.pardon = pardon;
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddPardonController>.reactive(
        viewModelBuilder: () => AddPardonController(pardon),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: white,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.black),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              title: Text("Demande de pardon", style: headerText),
              actions: [
                ValueListenableBuilder<bool>(
                  builder:
                      (BuildContext context, bool isSaving, Widget? child) {
                    return isSaving
                        ? BBloader()
                        : Center(
                            child: GestureDetector(
                              onTap: () {
                                controller.save();
                              },
                              child: Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Text('Partager',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w700))),
                            ),
                          );
                  },
                  valueListenable: controller.isSaving,
                )
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
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: ListView(
                  children: [
                    controller.isLoading
                        ? BBloader()
                        : Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UIHelper.verticalSpace(10),
                                TextFormField(
                                  maxLines: 1,
                                  initialValue: controller.newPardon.lastname,
                                  validator: ValidatorHelpers.validateName,
                                  onChanged: (text) {
                                    controller.newPardon.lastname = text;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      labelText: "Nom"),
                                ),
                                UIHelper.verticalSpace(15),
                                TextFormField(
                                  maxLines: 1,
                                  initialValue: controller.newPardon.firstname,
                                  validator: ValidatorHelpers.validateName,
                                  onChanged: (text) {
                                    controller.newPardon.firstname = text;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      labelText: "Prénom"),
                                ),
                                UIHelper.verticalSpace(15),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    maxLines: 6,
                                    maxLength: 2000,
                                    initialValue: controller.newPardon.content,
                                    onChanged: (text) {
                                      controller.newPardon.content = text;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: white,
                                        labelText: "Demande de pardon"),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            )));
  }
}

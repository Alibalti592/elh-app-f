import 'package:elh/common/theme.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/dece/AddDeceController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class AddDeceView extends StatefulWidget {
  Dece? dece;

  AddDeceView({dece}) {
    this.dece = dece;
  }

  @override
  AddDeceViewState createState() => AddDeceViewState(dece: this.dece);
}

class AddDeceViewState extends State<AddDeceView> {
  Dece? dece;
  AddDeceViewState({dece}) {
    this.dece = dece;
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddDeceController>.reactive(
        viewModelBuilder: () => AddDeceController(dece),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
                elevation: 0,
                iconTheme: new IconThemeData(color: Colors.white),
                backgroundColor: primaryColor,
                title: Text("Contacter des pompes funèbres",
                    style: headerTextWhite),
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
                                    child: Text('Enregistrer',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700))),
                              ),
                            );
                    },
                    valueListenable: controller.isSaving,
                  )
                ]),
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
                                TextFormField(
                                  maxLines: 1,
                                  initialValue: controller.newDece.lastname,
                                  validator: ValidatorHelpers.validateName,
                                  onChanged: (text) {
                                    controller.newDece.lastname = text;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      labelText: "Nom du défunt"),
                                ),
                                UIHelper.verticalSpace(15),
                                TextFormField(
                                  maxLines: 1,
                                  initialValue: controller.newDece.firstname,
                                  validator: ValidatorHelpers.validateName,
                                  onChanged: (text) {
                                    controller.newDece.firstname = text;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      labelText: "Prénom du défunt"),
                                ),
                                UIHelper.verticalSpace(10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('Date du décès',
                                      style: labelSmallStyle),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                      controller: controller.dateController,
                                      onTap: () {
                                        picker.DatePicker.showDatePicker(
                                            context,
                                            showTitleActions: true,
                                            onConfirm: (date) {
                                          controller.updateDate(date);
                                        },
                                            currentTime: DateTime.now(),
                                            maxTime: DateTime.now(),
                                            locale: picker.LocaleType.fr);
                                      },
                                      readOnly: true,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: white)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('Lieu du décès',
                                      style: labelSmallStyle),
                                ),
                                DropdownButtonFormField<String>(
                                    initialValue: controller.newDece.lieu,
                                    icon: Icon(MdiIcons.chevronDown),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(20),
                                    elevation: 16,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 0),
                                    style: const TextStyle(color: fontGreyDark),
                                    onChanged: (String? value) {
                                      controller.setLieuType(value);
                                    },
                                    items: _selectOptions(controller, 'lieu')),
                                UIHelper.verticalSpace(15),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: controller.adresse1Controller,
                                    onTap: () {
                                      controller.openSearchLocation(
                                          context, 'adresse1');
                                    },
                                    readOnly: true,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: white,
                                        labelText:
                                            controller.newDece.lieu == 'maison'
                                                ? "Adresse du défunt"
                                                : "Adresse de l'hôpital"),
                                  ),
                                ),
                                //notif pompe funebre
                                UIHelper.verticalSpace(10),
                                TextFormField(
                                  maxLines: 1,
                                  initialValue: controller.newDece.phone,
                                  onChanged: (text) {
                                    controller.newDece.firstname = text;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      labelText:
                                          "Téléphone pour être contacté"),
                                ),
                                UIHelper.verticalSpace(10),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            )));
  }

  List<DropdownMenuItem<String>> _selectOptions(
      AddDeceController controller, String type) {
    List<DropdownMenuItem<String>> options = [];
    Map<String, dynamic> listOptions = {};
    if (type == 'lieu') {
      listOptions = controller.listLieux;
    } else {
      listOptions = controller.listOptions;
    }
    listOptions.forEach((key, label) {
      options.add(DropdownMenuItem(
        value: key,
        child: Text(label, style: subHeaderStyle),
      ));
    });
    return options;
  }
}

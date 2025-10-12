import 'package:elh/common/elh_icons.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Salat/AddSalatController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class AddSalatView extends StatefulWidget {
  Salat? salat;
  String fromView;
  AddSalatView({salat, required this.fromView}) {
    this.salat = salat;
  }
  @override
  AddSalatViewState createState() =>
      AddSalatViewState(salat: this.salat, fromView: this.fromView);
}

class AddSalatViewState extends State<AddSalatView> {
  Salat? salat;
  String fromView;
  AddSalatViewState({salat, required this.fromView}) {
    this.salat = salat;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddSalatController>.reactive(
      viewModelBuilder: () => AddSalatController(salat, fromView),
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLightV2,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          title: Text("Ajouter une Salât", style: headerTextWhite),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              controller.goBack();
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
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
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ListView(
              children: [
                controller.isLoading
                    ? BBloader()
                    : Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lien avec le défunt
                            Text("Lien avec le défunt", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            controller.listAfiliations.isNotEmpty
                                ? DropdownButtonFormField<String>(
                                    value: controller.newSalat.afiliation,
                                    icon: Icon(MdiIcons.chevronDown),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(10),
                                    elevation: 16,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                    ),
                                    onChanged: (String? value) {
                                      controller.setAfiliation(value);
                                    },
                                    items: _selectOptions(
                                        controller, 'afiliation'),
                                  )
                                : Container(),
                            UIHelper.verticalSpace(15),

                            // Nom
                            Text("Nom", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            TextFormField(
                              maxLines: 1,
                              initialValue: controller.newSalat.lastname,
                              validator: ValidatorHelpers.validateName,
                              onChanged: (text) {
                                controller.newSalat.lastname = text;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: white,
                              ),
                            ),
                            UIHelper.verticalSpace(15),

                            // Prénom
                            Text("Prénom", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            TextFormField(
                              maxLines: 1,
                              initialValue: controller.newSalat.firstname,
                              validator: ValidatorHelpers.validateName,
                              onChanged: (text) {
                                controller.newSalat.firstname = text;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: white,
                              ),
                            ),
                            UIHelper.verticalSpace(15),

                            // Date de la Salât
                            Text("Date de la Salât", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            TextFormField(
                              controller: controller.dateController,
                              onTap: () {
                                picker.DatePicker.showDateTimePicker(
                                  context,
                                  showTitleActions: true,
                                  onConfirm: (date) {
                                    controller.updateDate(date);
                                  },
                                  currentTime: DateTime.now(),
                                  locale: picker.LocaleType.fr,
                                );
                              },
                              readOnly: true,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: white,
                              ),
                            ),
                            UIHelper.verticalSpace(15),

                            // Mosquée
                            Text("Mosquée", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            TextFormField(
                              controller: controller.mosqueController,
                              onTap: () {
                                if (!controller.manualMosque) {
                                  controller.openSearchMosque(context);
                                }
                              },
                              readOnly: !controller.manualMosque,
                              maxLines: 1,
                              decoration: InputDecoration(
                                suffixIcon: controller.manualMosque
                                    ? null
                                    : const Icon(Icons.search),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: white,
                              ),
                            ),
                            UIHelper.verticalSpace(15),

                            // Cimetière
                            Text("Cimetière", style: labelSmallStyle),
                            UIHelper.verticalSpace(5),
                            TextFormField(
                              maxLines: 1,
                              initialValue: controller.newSalat.cimetary,
                              validator: ValidatorHelpers.validateName,
                              onChanged: (text) {
                                controller.newSalat.cimetary = text;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: white,
                              ),
                            ),
                            UIHelper.verticalSpace(30),

                            // Bouton enregistrer
                            ValueListenableBuilder<bool>(
                              builder: (BuildContext context, bool isSaving,
                                  Widget? child) {
                                return isSaving
                                    ? BBloader()
                                    : Center(
                                        child: ElevatedButton(
                                          child: const Text("Enregistrer",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            controller.save();
                                          },
                                        ),
                                      );
                              },
                              valueListenable: controller.isSaving,
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _selectOptions(
      AddSalatController controller, String type) {
    List<DropdownMenuItem<String>> options = [];
    Map<String, dynamic> listAfiliations = {};
    if (type == 'lieu') {
      listAfiliations = controller.listLieux;
    } else {
      listAfiliations = controller.listAfiliations;
    }
    listAfiliations.forEach((key, label) {
      options.add(DropdownMenuItem(
        value: key,
        child: Text(label, style: subHeaderStyle),
      ));
    });
    return options;
  }
}

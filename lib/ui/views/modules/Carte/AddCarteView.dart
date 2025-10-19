import 'package:elh/common/theme.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Carte/AddCarteController.dart';
import 'package:elh/ui/views/modules/Carte/CardText.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class AddCarteView extends StatefulWidget {
  final Carte? carte;
  AddCarteView({this.carte});
  @override
  AddCarteViewState createState() => AddCarteViewState(carte: carte);
}

class AddCarteViewState extends State<AddCarteView> {
  final Carte? carte;
  final CardText _cardText = locator<CardText>();

  AddCarteViewState({this.carte});

  // 🔑 Helper for labeled text fields
  Widget labeledTextField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelSmallStyle),
        UIHelper.verticalSpace(5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          initialValue: controller == null ? initialValue : null,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        UIHelper.verticalSpace(15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddCarteController>.reactive(
      viewModelBuilder: () => AddCarteController(carte),
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLightV2,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          title: Text("Créer une carte virtuelle", style: headerTextWhite),
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
        extendBody: true,
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
                            // Carte Type Label
                            Center(
                              child: Text(
                                controller.carteTypeLabel(),
                                style: inTitleStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            UIHelper.verticalSpace(20),

                            // Special message for type == death
                            if (controller.newCarte.type == 'death') ...[
                              Center(
                                child: Text("Assalem Alaykoum",
                                    style: titleStyle,
                                    textAlign: TextAlign.center),
                              ),
                              UIHelper.verticalSpace(10),
                              Text(
                                controller.getDescription(),
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                              UIHelper.verticalSpace(15),
                            ],

                            // En mon nom ou pour un tiers
                            if (controller.newCarte.type != 'death' &&
                                controller.newCarte.type != 'searchdette') ...[
                              Text('En mon nom ou pour un tiers',
                                  style: labelSmallStyle),
                              UIHelper.verticalSpace(5),
                              DropdownButtonFormField<String>(
                                initialValue: controller.newCarte.onmyname,
                                icon: Icon(MdiIcons.chevronDown),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(20),
                                elevation: 16,
                                style: const TextStyle(color: fontGreyDark),
                                onChanged: controller.setForMeOrOther,
                                items: [
                                  DropdownMenuItem(
                                    value: 'myname',
                                    child: Text("En mon nom",
                                        style: subHeaderStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'toother',
                                    child: Text("Pour un tiers",
                                        style: subHeaderStyle),
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpace(15),
                            ],

                            // Lien avec le défunt
                            if (controller.showLienDefunt()) ...[
                              Text('Lien avec le défunt',
                                  style: labelSmallStyle),
                              UIHelper.verticalSpace(5),
                              if (controller.listAfiliations.isNotEmpty)
                                DropdownButtonFormField<String>(
                                  initialValue: controller.newCarte.afiliation,
                                  icon: Icon(MdiIcons.chevronDown),
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 16,
                                  style: const TextStyle(color: fontGreyDark),
                                  onChanged: controller.setAfiliation,
                                  items:
                                      _selectAfiliation(controller), // existing
                                ),
                              UIHelper.verticalSpace(15),
                            ],

                            // Nom & Prénom
                            if (controller.newCarte.onmyname == 'toother' ||
                                controller.newCarte.type == 'death') ...[
                              labeledTextField(
                                label: "Nom",
                                initialValue: controller.newCarte.lastname,
                                validator: ValidatorHelpers.validateName,
                                onChanged: (text) {
                                  controller.newCarte.lastname = text;
                                  controller.notifyListeners();
                                },
                              ),
                              labeledTextField(
                                label: "Prénom",
                                initialValue: controller.newCarte.firstname,
                                validator: ValidatorHelpers.validateName,
                                onChanged: (text) {
                                  controller.newCarte.firstname = text;
                                  controller.notifyListeners();
                                },
                              ),
                            ],

                            // Téléphone (searchdette only)
                            if (controller.newCarte.type == 'searchdette') ...[
                              Text('Personne à contacter',
                                  style: labelSmallStyle),
                              UIHelper.verticalSpace(5),
                              Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    controller.setPhoneNumber(number);
                                  },
                                  onInputValidated: (bool value) {},
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
                                    showFlags: true,
                                    setSelectorButtonAsPrefixIcon:
                                        true, // 🔑 fusionne avec input
                                    leadingPadding:
                                        10, // 🔑 colle le drapeau à gauche
                                  ),
                                  initialValue: controller.phoneNumber,
                                  textFieldController:
                                      controller.phoneController,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  formatInput: true,
                                  validator: ValidatorHelpers.validatePhone,
                                  keyboardType: TextInputType.phone,
                                  inputDecoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    hintText: "Téléphone",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(229, 231, 235, 1),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  spaceBetweenSelectorAndTextField:
                                      0, // 🔑 colle les deux
                                ),
                              ),
                              UIHelper.verticalSpace(15),
                            ],

                            // Date & Lieu décès (death only)
                            if (controller.newCarte.type == 'death') ...[
                              Text('Date du décès', style: labelSmallStyle),
                              UIHelper.verticalSpace(5),
                              TextFormField(
                                controller: controller.dateController,
                                onTap: () {
                                  picker.DatePicker.showDateTimePicker(context,
                                      showTitleActions: true,
                                      onConfirm: controller.updateDate,
                                      currentTime: DateTime.now(),
                                      locale: picker.LocaleType.fr);
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: white,
                                ),
                              ),
                              UIHelper.verticalSpace(15),
                              labeledTextField(
                                label: "Lieu du décès",
                                initialValue: controller.newCarte.locationName,
                                validator: ValidatorHelpers.validateName,
                                onChanged: (text) {
                                  controller.newCarte.locationName = text;
                                },
                              ),
                            ],

                            // Save button
                            ValueListenableBuilder<bool>(
                              valueListenable: controller.isSaving,
                              builder: (context, isSaving, child) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: isSaving
                                      ? BBloader()
                                      : ElevatedButton(
                                          onPressed: controller.save,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Enregistrer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),

                            // Middle content (death only)
                            if (controller.newCarte.type == 'death') ...[
                              UIHelper.verticalSpace(15),
                              Center(
                                child: Text(
                                  controller.getMiddleRamhou(),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],

                            // Generated content
                            ValueListenableBuilder<int>(
                              valueListenable: controller.updatedtext,
                              builder: (context, updatedText, child) {
                                return controller
                                        .getGeneratedContent()
                                        .isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          controller.getGeneratedContent(),
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),

                            // Bottom text
                            Center(
                              child: Text(
                                controller.getBottom(),
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
}

List<DropdownMenuItem<String>> _selectAfiliation(
    AddCarteController controller) {
  List<DropdownMenuItem<String>> options = [];
  controller.listAfiliations.forEach((key, label) {
    options.add(DropdownMenuItem(
      value: key,
      child: Text(label, style: subHeaderStyle),
    ));
  });
  return options;
}

List<DropdownMenuItem<String>> _selectTypes() {
  List<DropdownMenuItem<String>> options = [];
  options.add(DropdownMenuItem(
    value: 'pardon',
    child: Text("Demande de pardon", style: subHeaderStyle),
  ));
  options.add(DropdownMenuItem(
    value: 'invocation',
    child: Text("Demande d'invocation", style: subHeaderStyle),
  ));
  options.add(DropdownMenuItem(
    value: 'remercie',
    child: Text("Remerciements", style: subHeaderStyle),
  ));
  options.add(DropdownMenuItem(
    value: 'death',
    child: Text("Annoncer un décès", style: subHeaderStyle),
  ));

  return options;
}

__navCard(label, controller, type, {fontSize = 15.0}) {
  const bgWhithe = const Color(0xffffffff);
  return GestureDetector(
    onTap: () {
      controller.selectType(type);
    },
    child: Container(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        decoration: BoxDecoration(
          color: bgWhithe,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: Colors.black,
                  fontFamily: 'Karla'),
              textAlign: TextAlign.center,
            )
          ],
        )),
  );
}

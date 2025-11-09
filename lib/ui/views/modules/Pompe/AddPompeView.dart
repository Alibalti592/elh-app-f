import 'package:elh/models/pompe.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Pompe/AddPompeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';

class AddPompeView extends StatefulWidget {
  Pompe? pompe;

  AddPompeView({pompe}) {
    this.pompe = pompe;
  }
  @override
  AddPompeViewState createState() => AddPompeViewState(pompe: this.pompe);
}

class AddPompeViewState extends State<AddPompeView> {
  Pompe? pompe;
  AddPompeViewState({pompe}) {
    this.pompe = pompe;
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddPompeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text("Créer mon compte", style: headerTextWhite),
              backgroundColor: Colors.transparent,
              iconTheme: new IconThemeData(color: Colors.white),
              actions: [
                controller.step == 1
                    ? Container()
                    : ValueListenableBuilder<bool>(
                        builder: (BuildContext context, bool isSaving,
                            Widget? child) {
                          return isSaving
                              ? BBloader()
                              : Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.savePompe();
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
            body: SafeArea(
                child: ListView(children: [
              controller.step == 1
                  ? _textIntro(controller)
                  : Center(
                      child: controller.isLoading
                          ? BBloader()
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              child: Form(
                                key: controller.formKey,
                                child: Column(children: [
                                  inputForm(controller, 'name'),
                                  inputForm(controller, 'nameuser'),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: TextFormField(
                                      controller:
                                          controller.addressTextController,
                                      onTap: () {
                                        controller.openSearchLocation(context);
                                      },
                                      readOnly: true,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: white,
                                          labelText: "Adresse"),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      UIHelper.verticalSpace(5),
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: InternationalPhoneNumberInput(
                                          onInputChanged: (PhoneNumber number) {
                                            controller.setPhoneNumber(number);
                                          },
                                          onInputValidated: (bool value) {},
                                          selectorConfig: SelectorConfig(
                                            selectorType: PhoneInputSelectorType
                                                .BOTTOM_SHEET,
                                            showFlags: true,
                                          ),
                                          initialValue: controller.phoneNumber,
                                          hintText: 'Téléphone',
                                          locale: 'fr',
                                          ignoreBlank: false,
                                          autoValidateMode:
                                              AutovalidateMode.disabled,
                                          selectorTextStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                          textFieldController:
                                              controller.phoneController,
                                          formatInput: true,
                                          validator:
                                              ValidatorHelpers.validatePhone,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true, decimal: true),
                                          inputBorder: InputBorder.none,
                                          inputDecoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 5),
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "Téléphone",
                                          ),
                                          spaceBetweenSelectorAndTextField: 0,
                                        ),
                                      ),
                                      UIHelper.verticalSpace(10),
                                      inputForm(controller, 'emailPro'),
                                      UIHelper.verticalSpace(10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'Numéros d’urgence à contacter pour prise en charge du défunt',
                                            style: labelSmallStyle),
                                      ),
                                      Column(
                                        children: [
                                          UIHelper.verticalSpace(5),
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child:
                                                InternationalPhoneNumberInput(
                                              onInputChanged:
                                                  (PhoneNumber number) {
                                                controller
                                                    .setPhoneNumberUrgence(
                                                        number);
                                              },
                                              onInputValidated: (bool value) {},
                                              selectorConfig: SelectorConfig(
                                                selectorType:
                                                    PhoneInputSelectorType
                                                        .BOTTOM_SHEET,
                                                showFlags: true,
                                              ),
                                              initialValue:
                                                  controller.phoneNumberUrgence,
                                              hintText: 'Téléphone',
                                              locale: 'fr',
                                              ignoreBlank: false,
                                              autoValidateMode:
                                                  AutovalidateMode.disabled,
                                              selectorTextStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                              textFieldController: controller
                                                  .phoneControllerUrgence,
                                              formatInput: true,
                                              validator: ValidatorHelpers
                                                  .validatePhone,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true,
                                                      decimal: true),
                                              inputBorder: InputBorder.none,
                                              inputDecoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0,
                                                        vertical: 5),
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Téléphone urgence",
                                              ),
                                              spaceBetweenSelectorAndTextField:
                                                  0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      !controller.pompe!.validated
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  top: 35, left: 10, right: 10),
                                              child: Text(
                                                  "Assalem alaykoum, l’inscription de votre pompe funèbre sera effective après la validation de l’équipe Muslim Connect. Une notification te sera envoyée in sha allah.",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  textAlign: TextAlign.center))
                                          : Container(),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                    ),
            ]))),
        viewModelBuilder: () => AddPompeController(pompe));
  }

  Widget inputForm(AddPompeController controller, key, {maxLength = 25}) {
    String initValue = "";
    String label = "";
    int maxLines = 1;
    if (key == 'name') {
      initValue = controller.pompe!.name;
      label = "Nom de la pompe funèbre";
    } else if (key == 'emailPro') {
      initValue = controller.pompe!.emailPro;
      label = 'Adresse mail pro.';
      maxLines = 1;
    } else if (key == 'nameuser') {
      initValue = controller.pompe!.namePro;
      label = 'Nom du responsable';
      maxLines = 1;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        maxLines: maxLines,
        // maxLength: maxLength,
        initialValue: initValue,
        validator: ValidatorHelpers.validateName,
        onChanged: (text) {
          if (key == 'name') {
            controller.pompe!.name = text;
          } else if (key == 'nameuser') {
            controller.pompe!.namePro = text;
          } else if (key == 'emailPro') {
            controller.pompe!.emailPro = text;
          }
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: white,
            labelText: label),
      ),
    );
  }

  _textIntro(controller) {
    return Column(
      children: [
        UIHelper.verticalSpace(25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            children: [
              Text('Assalem alaykoum wa rhamatoullah wa barakatou.',
                  style: TextStyle(color: fontDark, fontSize: 17)),
              UIHelper.verticalSpace(15),
              Text(
                  "Tu es une pompe funèbre musulmane et tu souhaite proposer tes services grâce à notre plateforme de mise en relation.\n"
                  "Ton inscription est totalement gratuite.\n\nRejoignez-nous !",
                  style: TextStyle(color: fontDark, fontSize: 15)),
              UIHelper.verticalSpace(25),
              Text('BISMILLAH',
                  style: TextStyle(
                      color: fontDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        UIHelper.verticalSpace(10),
        TextButton(
          onPressed: () {
            controller.showForm();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: new Text(
              "Je crée mon compte",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor: WidgetStateProperty.all<Color>(primaryColor),
            backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            )),
          ),
        ),
        UIHelper.verticalSpace(40),
      ],
    );
  }
}

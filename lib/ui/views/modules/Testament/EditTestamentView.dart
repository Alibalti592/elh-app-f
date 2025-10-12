import 'package:elh/models/Testament.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Testament/EditTestamentController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class EditTestamentView extends StatefulWidget {
  late Testament testament;

  EditTestamentView(testament) {
    this.testament = testament;
  }

  @override
  EditTestamentViewState createState() =>
      EditTestamentViewState(this.testament);
}

class EditTestamentViewState extends State<EditTestamentView> {
  late Testament testament;

  EditTestamentViewState(testament) {
    this.testament = testament;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditTestamentController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),

              title: Text(controller.title, style: headerText),
              backgroundColor: Colors.transparent,
              // actions: [
              //   ValueListenableBuilder<bool>(
              //     builder: (BuildContext context, bool isSaving, Widget? child) {
              //       return isSaving ? BBloader() :  Center(
              //         child: GestureDetector(
              //           onTap: () {
              //             controller.saveTestament();
              //           },
              //           child: Container(
              //               padding: EdgeInsets.only(right: 15),
              //               child: Text('Enregistrer',
              //                   style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700))
              //           ),
              //         ),
              //       );
              //     },
              //     valueListenable: controller.isSaving,
              //   ),
              // ],
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
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                controller.saveTestament();
              },
              label: ValueListenableBuilder<bool>(
                builder: (BuildContext context, bool isSaving, Widget? child) {
                  return isSaving
                      ? BBloader()
                      : Container(
                          child: Text('Enregistrer',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Karla')));
                },
                valueListenable: controller.isSaving,
              ),
            ),
            body: SafeArea(
                child: ListView(
              children: [
                Center(
                  child: controller.isLoading
                      ? BBloader()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text('Bismillahi R-Rahmani R-Rahim',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: fontGreyDark)),
                                ),
                                UIHelper.verticalSpace(20),
                                testamentDe(controller.userInfos),
                                UIHelper.verticalSpace(20),
                                inputForm(controller, 'lastwill',
                                    "Je souhaite laisser les recommandations suivantes",
                                    maxLines: 25, maxLength: 10000),
                                inputForm(controller, 'location',
                                    "Je souhaite être enterré(e) selon les rites musulmans dans le pays et  ou ville suivante",
                                    maxLines: 3, maxLength: 500),
                                inputForm(controller, 'toilette',
                                    "Je souhaite que ma toilette mortuaire soit faite par",
                                    maxLines: 2, maxLength: 1000),
                                inputForm(controller, 'family',
                                    "Je souhaite pour mon enterrement aucunes bid’a et dans les conditions suivantes",
                                    maxLines: 7, maxLength: 3000),
                                inputForm(controller, 'fixe',
                                    "Je souhaite que l’on rembourse mes dettes de la manière suivante",
                                    maxLines: 7, maxLength: 3000),
                                inputForm(controller, 'goods',
                                    "Je souhaite que l’argent prêté et qui vous sera rendu soit utilisé de la manière suivante",
                                    maxLines: 5, maxLength: 3000),
                                UIHelper.verticalSpace(30),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ))),
        viewModelBuilder: () => EditTestamentController(testament));
  }

  Widget testamentDe(UserInfos? userInfos) {
    if (userInfos == null) {
      return Container();
    }
    return Center(
      child: UIHelper.h1(
          "Testament de : ${userInfos.firstname} ${userInfos.lastname}"),
    );
  }

  Widget inputForm(EditTestamentController controller, key, label,
      {maxLines = 1, maxLength = 25, type = 'string'}) {
    String initValue = controller.testament!.get(key).toString();
    if (initValue == "null") {
      initValue = "";
    }
    TextInputType keyboardType = TextInputType.multiline;
    List<TextInputFormatter>? inputFormatters = [];
    dynamic? validator;

    if (type == "string") {
      // validator = ValidatorHelpers.validateName;
    } else if (type == "string" && maxLines > 1) {
      keyboardType = TextInputType.multiline;
    } else if (type == "number") {
      keyboardType = TextInputType.numberWithOptions(decimal: true);
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(label, style: labelSmallStyle),
          ),
          UIHelper.verticalSpace(5),
          TextFormField(
            maxLines: maxLines,
            // maxLength: maxLength,
            initialValue: initValue,
            validator: validator,
            onChanged: (text) {
              if (type == "number") {
                text = text.replaceAll(',', '.');
                controller.testament.set(key, double.parse(text));
              } else {
                controller.testament.set(key, text);
              }
            },
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 14, color: fontGreyLight),
                floatingLabelStyle: TextStyle(color: fontGreyDark),
                filled: true,
                fillColor: white,
                labelText: ""),
          ),
        ],
      ),
    );
  }
}

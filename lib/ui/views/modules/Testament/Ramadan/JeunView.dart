import 'package:elh/models/Testament.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Testament/Ramadan/JeunController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class JeunView extends StatefulWidget {
  @override
  JeunViewState createState() => JeunViewState();
}

class JeunViewState extends State<JeunView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JeunController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(controller.title, style: headerText),
              backgroundColor: primaryColor,
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
                controller.saveJeun();
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
                                  fontFamily: 'inter')));
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text("Ramadan: ",
                                          style: labelSmallStyleB),
                                    ),
                                    UIHelper.horizontalSpace(90),
                                    Container(
                                      height: 50,
                                      width: 80,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: CupertinoPicker(
                                        selectionOverlay:
                                            CupertinoPickerDefaultSelectionOverlay(
                                          background: Colors
                                              .transparent, // Optional: remove gray overlay
                                        ),
                                        itemExtent: 32.0,
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem: controller.iniYearIndex,
                                        ),
                                        onSelectedItemChanged: (int index) {
                                          setState(() {
                                            controller.selectedYear =
                                                controller.yearList[index];
                                          });
                                        },
                                        children: controller.yearList
                                            .map((year) => Center(
                                                    child: Text(
                                                  year.toString(),
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                UIHelper.verticalSpace(20),
                                inputFormRow(controller, 'jeunNbDays',
                                    "Nombre de jours manqués:",
                                    maxLines: 1, maxLength: 10, type: "number"),
                                UIHelper.verticalSpace(10),
                                inputFormRow(controller, 'jeunNbDaysR',
                                    "Nombre de jours rattrapés:",
                                    maxLines: 1, maxLength: 10, type: "number"),
                                UIHelper.verticalSpace(20),
                                inputForm(controller, 'jeunText',
                                    "Notes ou informations particulières",
                                    maxLines: 10, maxLength: 10000),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ))),
        viewModelBuilder: () => JeunController());
  }

  Widget inputFormRow(JeunController controller, key, label,
      {maxLines = 1, maxLength = 25, type = 'string'}) {
    String initValue = controller.jeunText;
    if (key == "jeunNbDays") {
      initValue = controller.jeunNbDays.toString();
    }
    if (key == "jeunNbDaysR") {
      initValue = controller.jeunNbDaysR.toString();
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
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: labelSmallStyleB),
          ),
          UIHelper.verticalSpace(5),
          SizedBox(
            width: 80,
            height: 40,
            child: TextFormField(
              maxLines: 1,
              // maxLength: maxLength,
              initialValue: initValue,
              validator: validator,
              onChanged: (text) {
                if (type == "number") {
                  text = text.replaceAll(',', '.');
                }
                if (text == "") {
                  text = '0';
                }
                if (key == "jeunNbDays") {
                  controller.jeunNbDays = int.parse(text);
                }
                if (key == "jeunNbDaysR") {
                  controller.jeunNbDaysR = int.parse(text);
                }
              },
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(229, 231, 235, 1), width: 2),
                ),
                labelStyle: TextStyle(fontSize: 14, color: fontGreyLight),
                floatingLabelStyle: TextStyle(color: fontGreyDark),
                filled: true,
                fillColor: white,
                labelText: "",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputForm(JeunController controller, key, label,
      {maxLines = 1, maxLength = 25, type = 'string'}) {
    String initValue = controller.jeunText;
    if (key == "jeunNbDays") {
      initValue = controller.jeunNbDays.toString();
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
            child: Text(label, style: labelSmallStyleB),
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
              }
              if (key == "jeunNbDays") {
                controller.jeunNbDays = int.parse(text);
              } else {
                controller.jeunText = text;
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

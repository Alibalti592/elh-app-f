import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Maraude/AddMaraudeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class AddMaraudeView extends StatefulWidget {
  @override
  AddMaraudeViewState createState() => AddMaraudeViewState();
}

class AddMaraudeViewState extends State<AddMaraudeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMaraudeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              title: Text(controller.title, style: headerText),
              backgroundColor: Colors.transparent,
              actions: [
                ValueListenableBuilder<bool>(
                  builder:
                      (BuildContext context, bool isSaving, Widget? child) {
                    return isSaving
                        ? BBloader()
                        : Center(
                            child: GestureDetector(
                              onTap: () {
                                controller.saveMaraude();
                              },
                              child: Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Text('Enregistrer',
                                      style: TextStyle(
                                          color: primaryColor,
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
                                        labelText: "Ville"),
                                  ),
                                ),
                                UIHelper.verticalSpace(10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('Date & heure de la maraude',
                                      style: labelSmallStyle),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                      controller: controller.dateController,
                                      onTap: () {
                                        picker.DatePicker.showDateTimePicker(
                                            context,
                                            showTitleActions: true,
                                            onConfirm: (date) {
                                          controller.updateDate(date);
                                        },
                                            currentTime: DateTime.now(),
                                            locale: picker.LocaleType.fr);
                                      },
                                      readOnly: true,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: white)),
                                ),
                                inputForm(controller, 'description')
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ))),
        viewModelBuilder: () => AddMaraudeController());
  }

  Widget inputForm(AddMaraudeController controller, key, {maxLength = 25}) {
    String initValue = "";
    String label = "";
    int maxLines = 1;
    if (key == 'description') {
      initValue = controller.maraude.description;
      label = 'Description';
      maxLines = 6;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        maxLines: maxLines,
        // maxLength: maxLength,
        initialValue: initValue,
        validator: ValidatorHelpers.validateName,
        onChanged: (text) {
          if (key == 'description') {
            controller.maraude.description = text;
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
}

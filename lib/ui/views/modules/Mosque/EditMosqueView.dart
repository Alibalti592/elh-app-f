import 'package:elh/models/mosque.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/views/modules/Mosque/EditMosqueController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:stacked/stacked.dart';

class EditMosqueView extends StatefulWidget {
  Mosque? mosque;

  EditMosqueView({mosque}) {
    this.mosque = mosque;
  }
  @override
  EditMosqueViewState createState() => EditMosqueViewState(mosque: this.mosque);
}

class EditMosqueViewState extends State<EditMosqueView> {
  Mosque? mosque;
  EditMosqueViewState({mosque}) {
    this.mosque = mosque;
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditMosqueController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
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
                                controller.saveMosque();
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
                              children: [
                                TextField(
                                  controller: TextEditingController(
                                      text: controller.mosque!.description),
                                  decoration: InputDecoration(
                                    hintText: 'Hint text',
                                    contentPadding:
                                        const EdgeInsets.only(left: 10, top: 5),
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                  maxLines: null, // Allows multiple lines
                                  minLines: 5, // Minimum height for text input
                                  onChanged: (text) {
                                    controller.setDescription(text);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ))),
        viewModelBuilder: () => EditMosqueController(mosque));
  }

  Widget inputForm(EditMosqueController controller, key, {maxLength = 25}) {
    String initValue = "";
    String label = "";
    int maxLines = 1;
    if (key == 'description') {
      initValue = controller.mosque!.description;
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
          if (key == 'name') {
            controller.mosque!.name = text;
          } else if (key == 'description') {
            controller.mosque!.description = text;
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

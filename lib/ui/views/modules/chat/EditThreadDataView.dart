import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/chat/EditThreadDataController.dart';
import 'package:stacked/stacked.dart';

class EditThreadDataView extends StatelessWidget {
  final Thread thread;
  EditThreadDataView(this.thread);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditThreadDataController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: white,
            appBar: AppBar(
              title: Row(
                children: [
                  userThumbIconEmpty(
                      thread.image,
                      35.0,
                      thread.type == 'simple'
                          ? Icons.person_outline_outlined
                          : Icons.group_outlined,
                      16.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(thread.name),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              actions: [
                controller.isSaving
                    ? BBloader()
                    : GestureDetector(
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.save_outlined, color: primaryColor),
                        )),
                        onTap: () {
                          controller.saveThread();
                        },
                      ),
              ],
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Form(
                        key: controller.formKey,
                        child: Column(children: [
                          UIHelper.verticalSpaceMedium(),
                          Text("Photo du groupe",
                              style: TextStyle(color: fontGrey)),
                          UIHelper.verticalSpaceSmall(),
                          GestureDetector(
                            onTap: () {
                              controller.openSingleImagePicker();
                            },
                            child: Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: bgLight,
                                ),
                                child: Center(
                                    child: controller.imageFile != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(
                                                    controller.imageFile!,
                                                  ),
                                                )),
                                          )
                                        : userThumbDirect(
                                            thread.image, "", 80.0))),
                          ),
                          UIHelper.verticalSpaceMedium(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: TextFormField(
                              maxLines: 1,
                              maxLength: 60,
                              initialValue: controller.thread.groupName,
                              validator: ValidatorHelpers.validateName,
                              onChanged: (text) {
                                controller.thread.groupName = text;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: white,
                                  labelText: "Nom du groupe"),
                            ),
                          ),
                        ]))))),
        viewModelBuilder: () => EditThreadDataController(thread));
  }
}

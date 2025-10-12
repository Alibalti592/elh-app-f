import 'package:elh/ui/views/common/userThumb.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/user/ProfileModel.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';

class ProfileView extends StatefulWidget {
  final UserInfos userInfos;
  const ProfileView({Key? key, required this.userInfos}) : super(key: key);
  @override
  ProfileViewState createState() => ProfileViewState(userInfos);
}

class ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  final UserInfos userInfos;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  ProfileViewState(this.userInfos);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
        builder: (context, controller, child) => Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),

              elevation: 0,
              title: const Text('Mon compte',
                  style: TextStyle(
                    fontFamily: 'inter',
                    fontSize: 18,
                    color: white,
                  )),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              actions: [
                ValueListenableBuilder<bool>(
                  builder:
                      (BuildContext context, bool isSaving, Widget? child) {
                    return isSaving
                        ? BBloader()
                        : Center(
                            child: GestureDetector(
                              onTap: () {
                                controller.saveAccount();
                              },
                              child: Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Text('Enregistrer',
                                      style: TextStyle(
                                          color: white,
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
                      Color.fromRGBO(220, 198, 169, 1.0), // light beige
                      Color.fromRGBO(143, 151, 121, 1.0), // olive green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView(
                  children: [
                    UIHelper.verticalSpaceSmall(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      decoration: BoxDecoration(
                          // color: bgWhite,
                          ),
                      child: GestureDetector(
                        onTap: () {
                          _showOptionsChangePhoto(controller);
                        },
                        child: Column(
                          children: [
                            Text("Photo de profil",
                                style: TextStyle(color: fontGrey)),
                            UIHelper.verticalSpace(5),
                            Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: bgLight,
                                ),
                                child: Center(
                                    child: controller.profileFile != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(
                                                    controller.profileFile!,
                                                  ),
                                                )),
                                          )
                                        : userThumb(
                                            controller.userInfos, 50.0))),

                            UIHelper.verticalSpace(15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // aligns text to left

                              children: [
                                const Text(
                                  "Prenom",
                                  style: TextStyle(
                                    color: Color.fromRGBO(55, 65, 81, 1),
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                inputForm(
                                    controller,
                                    controller.userInfosForEdit.firstname,
                                    ValidatorHelpers.validateName,
                                    "Prénom",
                                    'firstname'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // aligns text to left

                              children: [
                                const Text(
                                  "Nom",
                                  style: TextStyle(
                                    color: Color.fromRGBO(55, 65, 81, 1),
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                inputForm(
                                    controller,
                                    controller.userInfosForEdit.lastname,
                                    ValidatorHelpers.validateName,
                                    "Nom",
                                    'lastname'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // aligns text to left

                              children: [
                                const Text(
                                  "Email",
                                  style: TextStyle(
                                    color: Color.fromRGBO(55, 65, 81, 1),
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                inputForm(
                                    controller,
                                    controller.userInfosForEdit.email,
                                    ValidatorHelpers.validateName,
                                    "Email",
                                    'email'),
                              ],
                            ),
                            //Tel
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Numéro de téléphone",
                                  style: TextStyle(
                                    color: Color.fromRGBO(55, 65, 81, 1),
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                InternationalPhoneNumberInput(
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
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  spaceBetweenSelectorAndTextField:
                                      0, // 🔑 colle les deux
                                ),
                              ],
                            ),
                            UIHelper.verticalSpace(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ville",
                                  style: TextStyle(
                                    color: Color.fromRGBO(55, 65, 81, 1),
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: controller.cityTextController,
                                    onTap: () {
                                      controller.openSearchLocation(context);
                                    },
                                    readOnly: true,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                            color: Color.fromRGBO(
                                                229, 231, 235, 1),
                                            width: 2),
                                      ),
                                      filled: true,
                                      fillColor: white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(40),
                    Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          controller.deleteAccount();
                        },
                        child: Text(
                          "Supprimer mon compte",
                          style: smallText,
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(10),
                  ],
                ),
              ),
            )),
        viewModelBuilder: () => ProfileViewModel(userInfos));
  }

  void _showOptionsChangePhoto(ProfileViewModel controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choisir une photo'),
              onTap: () {
                Navigator.pop(context);
                controller.openSingleImagePicker('profile');
              },
            ),
            controller.userInfos.photo != ""
                ? ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Supprimer la photo'),
                    onTap: () {
                      Navigator.pop(context);
                      controller.removeImage();
                    },
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Widget inputForm(ProfileViewModel controller, value, validator, label, key,
      {maxLength = 25}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        maxLines: 1,
        // maxLength: maxLength,
        initialValue: value,
        validator: validator,
        onChanged: (text) {
          if (key == 'firstname') {
            controller.userInfosForEdit.firstname = text;
          } else if (key == 'lastname') {
            controller.userInfosForEdit.lastname = text;
          } else if (key == 'city') {
            controller.userInfosForEdit.city = text;
          } else if (key == 'phone') {
            controller.userInfosForEdit.phone = text;
          } else if (key == 'email') {
            controller.newEmail = text;
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
                color: Color.fromRGBO(229, 231, 235, 1), width: 2),
          ),
          filled: true,
          fillColor: white,
        ),
      ),
    );
  }
}

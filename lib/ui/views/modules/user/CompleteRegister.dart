import 'dart:math';

import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class CompleteRegister extends StatelessWidget {
  PageController _controller =
      new PageController(initialPage: 1, viewportFraction: 1.0);
  @override
  Widget build(BuildContext context) {
    final bool _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return ViewModelBuilder<LoginModel>.reactive(
        builder: (context, model, child) => Container(
            height: MediaQuery.of(context).size.height,
            child: PageView(
              controller: _controller,
              physics: new AlwaysScrollableScrollPhysics(),
              children: <Widget>[signUpPage(context, model)],
              scrollDirection: Axis.horizontal,
            )),
        viewModelBuilder: () => LoginModel());
  }

  Widget signUpPage(BuildContext context, LoginModel model) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header beige ---
                      Container(
                        width: double.infinity,
                        color: const Color.fromRGBO(220, 198, 169, 1),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/logo-no-bg.png",
                              height: 80,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      // --- Main content ---
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 20),
                          child: AutofillGroup(
                            child: Form(
                              key: model.registerFormKey,
                              autovalidateMode: model.autoValidate
                                  ? AutovalidateMode.always
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),

                                  // Title
                                  Center(
                                    child: Text(
                                      "Créer un compte",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // First & Last name
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // 👈 important
                                        children: [
                                          // --- Firstname ---
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Prénom",
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        55, 65, 81, 1),
                                                    fontFamily: 'inter',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                TextFormField(
                                                  validator: ValidatorHelpers
                                                      .validateName,
                                                  autofillHints: const [
                                                    AutofillHints.givenName
                                                  ],
                                                  onChanged: (text) => model
                                                      .userRegistrationController(
                                                          'firstname', text),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    errorMaxLines:
                                                        3, // 👈 allows full text
                                                    errorStyle: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.red,
                                                      height: 1.3,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      vertical: 10,
                                                      horizontal: 12,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Color.fromRGBO(
                                                            229, 231, 235, 1),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          // --- Lastname ---
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Nom",
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        55, 65, 81, 1),
                                                    fontFamily: 'inter',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                TextFormField(
                                                  validator: ValidatorHelpers
                                                      .validateName,
                                                  autofillHints: const [
                                                    AutofillHints.familyName
                                                  ],
                                                  onChanged: (text) => model
                                                      .userRegistrationController(
                                                          'lastname', text),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    errorMaxLines:
                                                        3, // 👈 same fix
                                                    errorStyle: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.red,
                                                      height: 1.3,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      vertical: 10,
                                                      horizontal: 12,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Color.fromRGBO(
                                                            229, 231, 235, 1),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),

                                  // Phone
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
                                      model.setPhoneNumber(number);
                                    },
                                    onInputValidated: (bool value) {},
                                    selectorConfig: const SelectorConfig(
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET,
                                      showFlags: true,
                                      setSelectorButtonAsPrefixIcon: true,
                                      leadingPadding: 10,
                                    ),
                                    initialValue: model.phoneNumber,
                                    textFieldController: model.phoneController,
                                    autoValidateMode: AutovalidateMode.disabled,
                                    formatInput: true,
                                    validator: ValidatorHelpers.validatePhone,
                                    keyboardType: TextInputType.phone,
                                    inputDecoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(229, 231, 235, 1),
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
                                    spaceBetweenSelectorAndTextField: 0,
                                  ),
                                  UIHelper.verticalSpaceSmall(),
                                  const SizedBox(height: 15),

                                  // Checkbox CGU
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.2,
                                        child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: model.acceptCondition,
                                          onChanged: (value) => model
                                              .acceptConditionChange(value),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => model.openUrl(
                                              "https://muslim-connect.fr/cgu"),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: const Text.rich(
                                              TextSpan(
                                                text:
                                                    "J'accepte les conditions générales d’utilisation ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'inter',
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "CGU/CGV",
                                                    style: TextStyle(
                                                      color: primaryColorMiddle,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Register button
                                  ValueListenableBuilder<bool>(
                                    valueListenable: model.isRegistering,
                                    builder: (context, isRegistering, _) {
                                      return isRegistering
                                          ? BBloader()
                                          : SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                          143, 151, 121, 1),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  TextInput
                                                      .finishAutofillContext();
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  final emailGoogle =
                                                      prefs.getString(
                                                              'email_google') ??
                                                          '';

                                                  final randomPassword =
                                                      generateRandomPassword();

                                                  model
                                                      .userRegistrationController(
                                                          'password',
                                                          randomPassword);
                                                  model
                                                      .userRegistrationController(
                                                          'email', emailGoogle);

                                                  await model
                                                      .register(_controller);
                                                },
                                                child: const Text(
                                                  "S'inscrire",
                                                  style: TextStyle(
                                                    color: white,
                                                    fontFamily: 'inter',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String generateRandomPassword([int length = 12]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=<>?';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}

import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/app_colors.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/widgets/google_sign_up_button.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';
import 'package:elh/ui/widgets/google_sign_in_button.dart';
import 'package:elh/ui/views/modules/user/WelcomeDesign.dart';
import 'package:elh/ui/views/modules/user/LogoAndName.dart';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int initialPage = 1;
  Login({initialPage = 1}) {
    this.initialPage = 1;
  }
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
              children: <Widget>[
                loginPage(context, model, _keyboardVisible),
                // homePage(context, model),
                WelcomeDesign(
                  model: model,
                  onSignUpPressed: () => gotoSignup(model),
                  onLoginPressed: () => gotoLogin(),
                ),

                signUpPage(context, model)
              ],
              scrollDirection: Axis.horizontal,
            )),
        viewModelBuilder: () => LoginModel());
  }

  Widget homePage(context, model) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        // decoration: _backgroundImageGradient(
        //     Color(0xFFC4BBB2), Color(0xFFE1D8CE), Color(0xFFC4BBB2), 0.15),
        // color: Color.fromRGBO(240, 233, 223, 1),
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                _LogoAndName(model),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            foregroundColor:
                                MaterialStateProperty.all<Color>(primaryColor),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(primaryColor),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            )),
                          ),
                          onPressed: () => gotoSignup(model),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Créer un compte",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 23),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // BOUTON LOGIN
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new TextButton(
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            shape:
                                WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            )),
                          ),
                          onPressed: () => gotoLogin(),
                          child: new Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: Text(
                                    "Se connecter",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: greenElh),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                UIHelper.verticalSpaceSmall(),
                Center(child: Text('Version ${model.version}')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget loginPage(context, LoginModel model, _keyboardVisible) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 this enables page resizing
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // --- Header beige (stays fixed)
          Container(
            width: double.infinity,
            color: const Color.fromRGBO(220, 198, 169, 1),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            child: Column(
              children: [
                Image.asset("assets/images/logo-no-bg.png", height: 80),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // --- Main content (resizes when keyboard opens)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                // 👆 adds dynamic padding equal to keyboard height
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "Se connecter",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    const Text(
                      "Adresse e-mail",
                      style: TextStyle(
                        color: Color.fromRGBO(55, 65, 81, 1),
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.username
                      ],
                      decoration: InputDecoration(
                        hintText: "exemple@gmail.com",
                        prefixIcon: const Icon(Icons.email_outlined),
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
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    const Text(
                      "Mot de passe",
                      style: TextStyle(
                        color: Color.fromRGBO(55, 65, 81, 1),
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: model.obscureText,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        hintText: "************",
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(model.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => model.toggleObscureText(),
                        ),
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => model.gotToResetPassword(),
                        child: const Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color.fromRGBO(55, 65, 81, 1),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Error
                    ValueListenableBuilder<String?>(
                      valueListenable: model.globalError,
                      builder: (context, error, _) {
                        if (error == null || error.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),

                    // Login button
                    ValueListenableBuilder<bool>(
                      valueListenable: model.isLogging,
                      builder: (context, isLogging, _) {
                        return isLogging
                            ? BBloader()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(143, 151, 121, 1),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  var username =
                                      _usernameController.text.trim();
                                  var password = _passwordController.text;
                                  await model.login(username, password);
                                },
                                child: const Text(
                                  "Se connecter",
                                  style: TextStyle(
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Color.fromRGBO(143, 151, 121, 1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "Ou",
                            style: TextStyle(
                              fontFamily: 'inter',
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Color.fromRGBO(143, 151, 121, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // full width like other buttons
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child:
                          GoogleSignInButton(), // just call it, no need to pass context
                    ),
                    const SizedBox(height: 30),

                    // Bottom text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n’avez pas un compte? ",
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => gotoSignup(model),
                          child: const Text(
                            "S’inscrire",
                            style: TextStyle(
                              color: Color(0xFF7E846B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

                                  // Email
                                  const Text(
                                    "Adresse e-mail",
                                    style: TextStyle(
                                        color: Color.fromRGBO(55, 65, 81, 1),
                                        fontFamily: 'inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    validator: ValidatorHelpers.validateEmail,
                                    autofillHints: const [AutofillHints.email],
                                    onChanged: (text) =>
                                        model.userRegistrationController(
                                            'email', text),
                                    decoration: bbInputDecoration("").copyWith(
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
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
                                    ),
                                  ),
                                  const SizedBox(height: 15),

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

                                  // Password
                                  const Text(
                                    "Mot de passe",
                                    style: TextStyle(
                                      color: Color.fromRGBO(55, 65, 81, 1),
                                      fontFamily: 'inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    obscureText: model.obscureText,
                                    enableSuggestions: false,
                                    keyboardType: TextInputType.visiblePassword,
                                    validator:
                                        ValidatorHelpers.validatePassword,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    onChanged: (text) {
                                      model.userRegistrationController(
                                          'password', text);
                                    },
                                    decoration: bbInputDecoration('').copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          model.obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          model.toggleObscureText();
                                        },
                                      ),
                                    ),
                                    onEditingComplete: () =>
                                        TextInput.finishAutofillContext(),
                                  ),
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
                                              "https://test.muslim-connect.fr/cgu"),
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
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: Divider(
                                          thickness: 2,
                                          color:
                                              Color.fromRGBO(143, 151, 121, 1),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Text(
                                          "Ou",
                                          style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          thickness: 2,
                                          color:
                                              Color.fromRGBO(143, 151, 121, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width, // full width like other buttons
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 10.0),
                                    child:
                                        GoogleSignUpButton(), // just call it, no need to pass context
                                  ),
                                  const SizedBox(height: 15),

                                  // Google Sign-in Button
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   child: GoogleSignInButton(),
                                  // ),
                                  const SizedBox(height: 20),

                                  // Already have account
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Vous avez déjà un compte? ",
                                          style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          )),
                                      GestureDetector(
                                        onTap: () => gotoLogin(),
                                        child: const Text("Se connecter",
                                            style: TextStyle(
                                              fontFamily: 'inter',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            )),
                                      ),
                                    ],
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

  gotoLogin() {
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  gotoSignup(model) {
    model.resetShowIntro();
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  _backgroundImageGradient(color1, color2, color3, blend) {
    return BoxDecoration(
      gradient: new LinearGradient(
          colors: [color3, color2, color1],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 1.0),
          stops: [0.0, 0.5, 1.0],
          tileMode: TileMode.clamp),
      image: DecorationImage(
        colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(blend), BlendMode.dstATop),
        image: AssetImage('assets/images/bg_home.jpg'),
        fit: BoxFit.cover,
      ),
    );
  }

  _backgroundImageSimple() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/bg.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  _textIntro(LoginModel controller) {
    return Column(
      children: [
        UIHelper.verticalSpace(25),
        HtmlWidget(controller.introtext,
            textStyle: TextStyle(fontSize: 16),
            onTapUrl: (url) => controller.openUrl(url)),
        UIHelper.verticalSpace(20),
        TextButton(
          onPressed: () {
            controller.showregisterForm();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: new Text(
              "Rejoindre la communauté",
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
            foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
            backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            )),
          ),
        ),
        UIHelper.verticalSpace(40),
      ],
    );
  }
}

class _LogoAndName extends StatelessWidget {
  late LoginModel model;
  bool _keyboardVisible = false;
  _LogoAndName(model, {keyboardVisible = false}) {
    this.model = model;
    this._keyboardVisible = keyboardVisible;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: this._keyboardVisible
            ? EdgeInsets.only(top: 30.0, bottom: 30.0)
            : EdgeInsets.only(top: 120.0, bottom: 40.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                  child: Image(
                image: AssetImage("assets/images/logo-no-bg.png"),
                height: this._keyboardVisible ? 110 : 180,
              )),
            ),
          ],
        ));
  }
}

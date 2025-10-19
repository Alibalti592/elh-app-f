// import 'package:elh/common/theme.dart';
// import 'package:elh/ui/shared/BBLoader.dart';
// import 'package:elh/ui/shared/text_styles.dart';
// import 'package:elh/ui/shared/ui_helpers.dart';
// import 'package:elh/ui/views/modules/user/LogoAndName.dart';
// import 'package:elh/ui/views/modules/user/ResetPasswordController.dart';
// import 'package:flutter/material.dart';
// import 'package:stacked/stacked.dart';

// class ResetPasswordView extends StatefulWidget {
//   ResetPasswordView();
//   @override
//   ResetPasswordViewState createState() => ResetPasswordViewState();
// }

// class ResetPasswordViewState extends State<ResetPasswordView> {
//   @override
//   Widget build(BuildContext context) {
//     final bool _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
//     return ViewModelBuilder<ResetPasswordController>.reactive(
//         viewModelBuilder: () => ResetPasswordController(),
//         builder: (context, controller, child) => Container(
//             height: MediaQuery.of(context).size.height,
//             child: Scaffold(
//                 body: Container(
//               height: MediaQuery.of(context).size.height,
//               decoration: _backgroundImageSimple(),
//               child: AutofillGroup(
//                 child: ListView(
//                   children: <Widget>[
//                     LogoAndName(keyboardVisible: _keyboardVisible),
//                     controller.showResetUI
//                         ? _resetUI(controller)
//                         : Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                     left: 25.0,
//                                     right: 25.0,
//                                     top: 0.0,
//                                     bottom: 20),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Mot de passe oublié',
//                                         style: inTitleStyle),
//                                     Text(
//                                         "Saisissez l'adresse email utilisée comme identifiant sur l'application."
//                                         "Un mail contenant une code pour réinitiliser votre mot de passe sera envoyé.",
//                                         style: TextStyle(
//                                             color: fontGreyDark, fontSize: 14)),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width,
//                                 margin: const EdgeInsets.only(
//                                     left: 25.0,
//                                     right: 25.0,
//                                     top: 10.0,
//                                     bottom: 20),
//                                 alignment: Alignment.center,
//                                 padding: const EdgeInsets.only(
//                                     left: 0.0, right: 10.0),
//                                 child: new Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: <Widget>[
//                                     new Expanded(
//                                       child: TextField(
//                                           autofillHints: const [
//                                             AutofillHints.email,
//                                             AutofillHints.username,
//                                             AutofillHints.newUsername,
//                                           ],
//                                           keyboardType:
//                                               TextInputType.emailAddress,
//                                           controller:
//                                               controller.usernameController,
//                                           autofocus: true,
//                                           textAlign: TextAlign.left,
//                                           decoration: bbInputDecoration(
//                                               'Votre email ...')),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               new Container(
//                                 width: MediaQuery.of(context).size.width,
//                                 margin: const EdgeInsets.only(
//                                     left: 30.0,
//                                     right: 30.0,
//                                     top: 0.0,
//                                     bottom: 10),
//                                 alignment: Alignment.center,
//                                 child: new Row(
//                                   children: <Widget>[
//                                     new Expanded(
//                                       child: controller.isLoading
//                                           ? Center(child: BBloader())
//                                           : TextButton(
//                                               style: ButtonStyle(
//                                                 visualDensity:
//                                                     VisualDensity.compact,
//                                                 foregroundColor:
//                                                     MaterialStateProperty.all<
//                                                         Color>(primaryColor),
//                                                 backgroundColor:
//                                                     MaterialStateProperty.all<
//                                                         Color>(primaryColor),
//                                                 shape:
//                                                     MaterialStateProperty.all(
//                                                         RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       new BorderRadius.circular(
//                                                           30.0),
//                                                 )),
//                                               ),
//                                               onPressed: () async {
//                                                 var username = controller
//                                                     .usernameController.text;
//                                                 username.trim();
//                                                 await controller
//                                                     .resetPassword(username);
//                                               },
//                                               child: new Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                   vertical: 15.0,
//                                                   horizontal: 20.0,
//                                                 ),
//                                                 child: new Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: <Widget>[
//                                                     new Expanded(
//                                                       child: Text(
//                                                         "Envoyer un code",
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               UIHelper.verticalSpace(40),
//                               GestureDetector(
//                                 onTap: () {
//                                   controller.goBack();
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       "Me connecter",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           color: fontGrey, fontSize: 16),
//                                     ),
//                                     UIHelper.horizontalSpace(5),
//                                     Icon(
//                                       Icons.arrow_forward_outlined,
//                                       color: fontGrey,
//                                       size: 15,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(15.0),
//                                 child: Text(
//                                     "Difficulté d’accès à votre compte ? Contactez-nous sur contact@muslim-connect.fr",
//                                     style: TextStyle(
//                                         color: fontGrey, fontSize: 15),
//                                     textAlign: TextAlign.center),
//                               )
//                             ],
//                           ),
//                     UIHelper.verticalSpace(15),
//                   ],
//                 ),
//               ),
//             ))));
//   }

//   // _resetUI(ResetPasswordController controller) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
//   //     child: Column(
//   //       children: [
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text('Définir mon mot de passe', style: inTitleStyle),
//   //             Text("Saisissez le code de validation reçu par mail et vore nouveau mot de passe.", style: TextStyle(color: fontGreyDark, fontSize: 14)),
//   //           ],
//   //         ),
//   //         UIHelper.verticalSpace(20),
//   //         TextField(
//   //             controller: controller.codeController,
//   //             autofocus: true,
//   //             textAlign: TextAlign.left,
//   //             decoration: bbInputDecoration('Code reçu par email')
//   //         ),
//   //         UIHelper.verticalSpace(25),
//   //         //mt de pass
//   //         TextField(
//   //             controller: controller.newpasswordController,
//   //             autofillHints: const [AutofillHints.password],
//   //             obscureText: controller.obscureText,
//   //             textAlign: TextAlign.left,
//   //             decoration:  bbInputDecoration("Nouveau mot de passe").copyWith(
//   //               suffixIcon: IconButton(
//   //                 icon: Icon(
//   //                   controller.obscureText ? Icons.visibility_off : Icons.visibility,
//   //                 ),
//   //                 onPressed: () {
//   //                   controller.toogleobscureText();
//   //                 },
//   //               ),
//   //             )
//   //         ),
//   //         UIHelper.verticalSpace(20),
//   //         controller.isLoading ? Center(child: BBloader()) : TextButton(
//   //           style: ButtonStyle(
//   //             visualDensity: VisualDensity.compact,
//   //             foregroundColor:
//   //             MaterialStateProperty.all<Color>(
//   //                 primaryColor),
//   //             backgroundColor:
//   //             MaterialStateProperty.all<Color>(
//   //                 primaryColor),
//   //             shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))),
//   //           ),
//   //           onPressed: () {
//   //             controller.confirmResetPassword();
//   //           },
//   //           child: new Container(
//   //             padding: const EdgeInsets.symmetric(
//   //               vertical: 15.0,
//   //               horizontal: 20.0,
//   //             ),
//   //             child: Text(
//   //               "Réinitialiser mon mot de passe",
//   //               textAlign: TextAlign.center,
//   //               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//   //             ),
//   //           ),
//   //         ),
//   //         UIHelper.verticalSpace(40),
//   //         GestureDetector(
//   //           onTap: () {
//   //             controller.goBack();
//   //           },
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.center,
//   //             children: [
//   //               Text(
//   //                 "Me connecter",
//   //                 textAlign: TextAlign.center,
//   //                 style: TextStyle(color: fontGrey, fontSize: 16),
//   //               ),
//   //               UIHelper.horizontalSpace(5),
//   //               Icon(Icons.arrow_forward_outlined, color: fontGrey, size: 15,)
//   //             ],
//   //           ),
//   //         ),
//   //         UIHelper.verticalSpace(20),
//   //         Padding(
//   //           padding: const EdgeInsets.all(0.0),
//   //           child: Text("Difficulté d’accès à votre compte ? Contactez-nous sur contact@muslim-connect.fr",
//   //               style: TextStyle(color: fontGrey, fontSize: 15), textAlign: TextAlign.center),
//   //         ),
//   //         UIHelper.verticalSpace(20)
//   //       ],
//   //     ),
//   //   );
//   // }
//   _resetUI(ResetPasswordController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
//       child: Column(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Définir mon mot de passe', style: inTitleStyle),
//               Text(
//                 "Saisissez le code de validation reçu par email et votre nouveau mot de passe",
//                 style: TextStyle(color: fontGreyDark, fontSize: 14),
//               ),
//             ],
//           ),
//           UIHelper.verticalSpace(20),

//           // Code input
//           TextField(
//             controller: controller.codeController,
//             decoration: bbInputDecoration('Code reçu par email'),
//           ),
//           UIHelper.verticalSpace(20),

//           // New password input
//           TextField(
//             controller: controller.newpasswordController,
//             obscureText: controller.obscureText,
//             decoration: bbInputDecoration("Nouveau mot de passe").copyWith(
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   controller.obscureText
//                       ? Icons.visibility_off
//                       : Icons.visibility,
//                 ),
//                 onPressed: controller.toogleobscureText,
//               ),
//             ),
//           ),
//           UIHelper.verticalSpace(25),

//           // Confirm button
//           controller.isLoading
//               ? Center(child: BBloader())
//               : TextButton(
//                   style: ButtonStyle(
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(Colors.white),
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(primaryColor),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                   onPressed: controller.confirmResetPassword,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 15.0),
//                     child: Text(
//                       "Confirmer",
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),

//           UIHelper.verticalSpace(20),

//           // "Se connecter"
//           GestureDetector(
//             onTap: controller.goBack,
//             child: Text(
//               "Se connecter",
//               style: TextStyle(
//                 color: fontGrey,
//                 fontSize: 16,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),

//           UIHelper.verticalSpace(20),

//           // Footer
//           Text(
//             "Difficulté d’accès à votre compte ? Contactez-nous sur contact@muslim-connect.fr",
//             style: TextStyle(color: fontGrey, fontSize: 13),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   _backgroundImageSimple() {
//     return BoxDecoration(
//       image: DecorationImage(
//         image: AssetImage('assets/images/bg.png'),
//         fit: BoxFit.cover,
//       ),
//     );
//   }
// }
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/user/ResetPasswordController.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ResetPasswordView extends StatefulWidget {
  @override
  ResetPasswordViewState createState() => ResetPasswordViewState();
}

class ResetPasswordViewState extends State<ResetPasswordView> {
  @override
  Widget build(BuildContext context) {
    final bool _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return ViewModelBuilder<ResetPasswordController>.reactive(
      viewModelBuilder: () => ResetPasswordController(),
      builder: (context, controller, child) => Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 🔹 HEADER (fond beige + logo + tagline)
            Container(
              width: double.infinity,
              color: Color.fromRGBO(220, 198, 169, 1),
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

            // 🔹 CONTENT
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  controller.showResetUI
                      ? _resetPasswordUI(controller)
                      : _forgotPasswordUI(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------------------
  /// 1ère étape : Mot de passe oublié
  /// -------------------------------
  Widget _forgotPasswordUI(ResetPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mot de passe oublié                       ",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'inter')),
        UIHelper.verticalSpace(10),
        const Text(
          "Saisissez l’adresse email utilisée comme identifiant sur l’application. "
          "Un mail contenant un code pour réinitialiser votre mot de passe sera envoyé.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color.fromRGBO(55, 65, 81, 1),
              fontSize: 14,
              fontFamily: 'inter',
              fontWeight: FontWeight.w500),
        ),
        UIHelper.verticalSpace(40),

        // Champ email
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
        TextField(
          controller: controller.usernameController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration("", "exemple@gmail.com").copyWith(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 231, 235, 1), width: 2),
            ),
          ),
        ),
        UIHelper.verticalSpace(25),

        // Bouton Envoyer
        controller.isLoading
            ? const Center(child: BBloader())
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () async {
                    var username = controller.usernameController.text.trim();
                    await controller.resetPassword(username);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Envoyer",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
        UIHelper.verticalSpace(20),

        // Lien Se connecter
        Center(
          child: GestureDetector(
            onTap: controller.goBack,
            child: const Text(
              "Se connecter",
              style: TextStyle(
                  color: Color.fromRGBO(55, 65, 81, 1),
                  fontSize: 15,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
        const SizedBox(height: 170),
        const Text(
          "Difficulté d’accès à votre compte ? Contactez-nous sur contact@muslim-connect.fr",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(55, 65, 81, 1),
            fontFamily: 'inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// -------------------------------------
  /// 2ème étape : Définir mon mot de passe
  /// -------------------------------------
  Widget _resetPasswordUI(ResetPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Définir mon mot de passe            ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),

        UIHelper.verticalSpace(10),
        const Text(
          "Saisissez le code de validation reçu par email et votre nouveau mot de passe",
          style: TextStyle(
              color: Color.fromRGBO(55, 65, 81, 1),
              fontSize: 14,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        UIHelper.verticalSpace(20),

        // Code reçu
        const Text(
          "Code recu par email",
          style: TextStyle(
              color: Color.fromRGBO(55, 65, 81, 1),
              fontFamily: 'inter',
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        const SizedBox(height: 5),

        TextField(
            controller: controller.codeController,
            decoration: _inputDecoration("", "").copyWith(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                    color: Color.fromRGBO(229, 231, 235, 1), width: 2),
              ),
            )),
        UIHelper.verticalSpace(20),

        // Nouveau mot de passe
        const Text(
          "Nouveau mot de passe",
          style: TextStyle(
              color: Color.fromRGBO(55, 65, 81, 1),
              fontFamily: 'inter',
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        const SizedBox(height: 5),

        TextField(
          controller: controller.newpasswordController,
          obscureText: controller.obscureText,
          decoration: _inputDecoration("", "").copyWith(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 231, 235, 1), width: 2),
            ),
          ),
        ),
        UIHelper.verticalSpace(25),

        // Bouton Confirmer
        controller.isLoading
            ? const Center(child: BBloader())
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: controller.confirmResetPassword,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Confirmer",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
        UIHelper.verticalSpace(20),

        // Lien Se connecter
        Center(
          child: GestureDetector(
            onTap: controller.goBack,
            child: const Text(
              "Se connecter",
              style: TextStyle(
                  color: Color.fromRGBO(55, 65, 81, 1),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
        const SizedBox(height: 110),
        const Text(
          "Difficulté d’accès à votre compte ? Contactez-nous sur contact@muslim-connect.fr",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(55, 65, 81, 1),
            fontFamily: 'inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Champs de saisie uniformisés
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  /// Style des boutons verts
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6D7A55), // vert
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

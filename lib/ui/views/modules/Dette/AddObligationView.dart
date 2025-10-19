// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
//     as picker;
// import 'package:stacked/stacked.dart';
// import 'package:elh/ui/shared/BBLoader.dart';
// import 'package:elh/ui/shared/Validators.dart';
// import 'package:elh/ui/shared/text_styles.dart';
// import 'package:elh/ui/shared/ui_helpers.dart';
// import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';
// import 'package:elh/models/Obligation.dart';
// import 'package:elh/common/theme.dart';
// import 'package:elh/ui/widgets/Upload_file_field.dart';

// class AddObligationView extends StatefulWidget {
//   final String type;
//   final Obligation? obligation;

//   AddObligationView(this.type, {this.obligation});

//   @override
//   AddObligationViewState createState() =>
//       AddObligationViewState(type, obligation: obligation);
// }

// class AddObligationViewState extends State<AddObligationView> {
//   final String type;
//   final Obligation? obligation;

//   AddObligationViewState(this.type, {this.obligation});

//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<AddObligationController>.reactive(
//       viewModelBuilder: () => AddObligationController(type, obligation),
//       builder: (context, controller, child) {
//         return Scaffold(
//           backgroundColor: white,
//           appBar: AppBar(
//             title: Text(controller.title, style: headerTextWhite),
//             flexibleSpace: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromRGBO(220, 198, 169, 1),
//                     Color.fromRGBO(143, 151, 121, 1),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//             elevation: 0,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           body: SafeArea(
//             child: controller.isLoading
//                 ? const Center(child: BBloader())
//                 : ListView(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 15),
//                     children: [
//                       Form(
//                         key: controller.formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Text(
//                                 'Bismillahi R-Rahmani R-Rahim, ${controller.accordEntre()}',
//                                 style: const TextStyle(
//                                     fontFamily: 'inter',
//                                     fontSize: 14,
//                                     color: Color.fromRGBO(55, 65, 81, 1)),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             UIHelper.verticalSpace(5),
//                             Center(
//                               child: Text(
//                                 controller.currentUserfullname,
//                                 style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10.0, vertical: 10.0),
//                               child: Center(
//                                 child: Text(
//                                   'a emprunter à ',
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 10),

//                             // Emprunteur Section
//                             controller.isEdit
//                                 ? Text(
//                                     controller.otherPersonName,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black),
//                                   )
//                                 : controller.showPersonSelectType
//                                     ? Column(
//                                         children: [
//                                           controller.showPersonFormDetails
//                                               ? Column(
//                                                   children: [
//                                                     inputForm(controller,
//                                                         'firstname', 'Prénom',
//                                                         textController: controller
//                                                             .firstnameTextController),
//                                                     inputForm(controller,
//                                                         'lastname', 'Nom',
//                                                         textController: controller
//                                                             .lastNameTextController),
//                                                     inputForm(controller, 'tel',
//                                                         'Téléphone',
//                                                         textController: controller
//                                                             .phoneTextController),
//                                                     UIHelper.verticalSpace(5),
//                                                   ],
//                                                 )
//                                               : personSelectionOptions(
//                                                   controller),
//                                         ],
//                                       )
//                                     : Center(
//                                         // <-- Center the button
//                                         child: ElevatedButton(
//                                           onPressed: () =>
//                                               controller.addPersonSelectType(),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor:
//                                                 const Color.fromRGBO(143, 151,
//                                                     121, 1), // RGBA background
//                                             foregroundColor:
//                                                 Colors.white, // Text color
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 25, vertical: 12),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             elevation: 2,
//                                           ),
//                                           child: Text(
//                                             controller.getPersonneLabel(),
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                       ),

//                             const SizedBox(height: 10),

//                             // Date Created
//                             Container(
//                               child: Text(
//                                 controller.getDateLabel(),
//                                 style: TextStyle(
//                                     color: Color.fromRGBO(55, 65, 81, 1),
//                                     fontSize: 15,
//                                     fontFamily: 'inter',
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                             UIHelper.verticalSpace(3),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                   2), // clip child to small radius
//                               child: Material(
//                                 elevation: 1, // subtle shadow
//                                 child: TextFormField(
//                                   controller: controller.dateStartController,
//                                   readOnly: true,
//                                   onTap: () {
//                                     picker.DatePicker.showDatePicker(
//                                       context,
//                                       showTitleActions: true,
//                                       onConfirm: (date) {
//                                         controller.updateDate(date);
//                                       },
//                                       currentTime: DateTime.now(),
//                                       locale: picker.LocaleType.fr,
//                                     );
//                                   },
//                                   decoration: InputDecoration(
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(2),
//                                       borderSide: const BorderSide(
//                                           color:
//                                               Color.fromRGBO(229, 231, 235, 1),
//                                           width: 2),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(2),
//                                       borderSide: const BorderSide(
//                                           color:
//                                               Color.fromRGBO(229, 231, 235, 1),
//                                           width: 2),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(2),
//                                       borderSide: const BorderSide(
//                                           color:
//                                               Color.fromRGBO(229, 231, 235, 1),
//                                           width: 2),
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),

//                             // Amount / Raison Fields
//                             if (controller.obligation.type != 'amana') ...[
//                               inputForm(controller, 'amount', 'Montant en €',
//                                   type: 'number'),
//                               inputForm(
//                                   controller, 'delay', controller.raisonText(),
//                                   maxLines: 1),
//                             ] else ...[
//                               inputForm(
//                                   controller, 'raison', 'Détails de la amana',
//                                   maxLines: 5),
//                             ],

//                             // Date de remboursement
//                             if (controller.obligation.type != 'amana') ...[
//                               Container(
//                                   child: Text(
//                                 'Date de remboursement au plus tard',
//                                 style: TextStyle(
//                                     color: Color.fromRGBO(55, 65, 81, 1),
//                                     fontSize: 15,
//                                     fontFamily: 'inter',
//                                     fontWeight: FontWeight.w600),
//                               )),
//                               UIHelper.verticalSpace(3),
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(
//                                     2), // clip child to small radius
//                                 child: Material(
//                                   elevation: 1, // subtle shadow
//                                   child: TextFormField(
//                                     controller: controller.dateStartController,
//                                     readOnly: true,
//                                     onTap: () {
//                                       picker.DatePicker.showDatePicker(
//                                         context,
//                                         showTitleActions: true,
//                                         onConfirm: (date) {
//                                           controller.updateDate(date);
//                                         },
//                                         currentTime: DateTime.now(),
//                                         locale: picker.LocaleType.fr,
//                                       );
//                                     },
//                                     decoration: InputDecoration(
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(2),
//                                         borderSide: const BorderSide(
//                                             color: Color.fromRGBO(
//                                                 229, 231, 235, 1),
//                                             width: 2),
//                                       ),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(2),
//                                         borderSide: const BorderSide(
//                                             color: Color.fromRGBO(
//                                                 229, 231, 235, 1),
//                                             width: 2),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(2),
//                                         borderSide: const BorderSide(
//                                             color: Color.fromRGBO(
//                                                 229, 231, 235, 1),
//                                             width: 2),
//                                       ),
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 12),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],

//                             const SizedBox(height: 20),
//                             // UploadFileWidget(controller: controller),

// // Save Button
//                             ValueListenableBuilder<bool>(
//                               valueListenable: controller.isSaving,
//                               builder: (context, isSaving, child) {
//                                 return Center(
//                                   child: isSaving
//                                       ? const BBloader()
//                                       : ElevatedButton(
//                                           onPressed: () {
//                                             if (controller.formKey.currentState!
//                                                 .validate()) {
//                                               controller.formKey.currentState!
//                                                   .save();
//                                               controller.saveObligation();
//                                             }
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: primaryColor,
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 25, vertical: 10),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             controller.toConfirm
//                                                 ? "Confirmer"
//                                                 : "Enregistrer",
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                 );
//                               },
//                             ),
//                             UIHelper.verticalSpace(20),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         );
//       },
//     );
//   }

//   /// Widget for person selection options
//   Widget personSelectionOptions(AddObligationController controller) {
//     return Column(
//       children: [
//         if (controller.canOpenPhoneContacts)
//           Column(
//             children: [
//               GestureDetector(
//                 onTap: () => controller.listPhoneContact(),
//                 child: optionContainer('Rechercher un contact du téléphone'),
//               ),
//               UIHelper.verticalSpace(5),
//               const Center(child: Text('OU')),
//             ],
//           ),
//         GestureDetector(
//           onTap: () => controller.searchContact(),
//           child: optionContainer('Rechercher un contact Muslim Connect'),
//         ),
//         UIHelper.verticalSpace(5),
//         const Center(child: Text('OU')),
//         GestureDetector(
//           onTap: () => controller.tglePersonFormDetails(),
//           child: optionContainer('Créer un contact'),
//         ),
//       ],
//     );
//   }

//   /// Standard container for person selection
//   Widget optionContainer(String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//       margin: const EdgeInsets.only(bottom: 5),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: Colors.grey, width: 2)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 15,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w700)),
//           const SizedBox(width: 10),
//           const Icon(Icons.arrow_forward_ios, size: 18)
//         ],
//       ),
//     );
//   }

//   Widget inputForm(AddObligationController controller, String key, String label,
//       {int maxLines = 1,
//       int maxLength = 25,
//       String type = 'string',
//       TextEditingController? textController}) {
//     String initValue = controller.obligation!.get(key)?.toString() ?? '';
//     TextInputType keyboardType = TextInputType.multiline;
//     List<TextInputFormatter>? inputFormatters = [];
//     dynamic validator;

//     if (type == "string") {
//       validator = ValidatorHelpers.validateName;
//       if (maxLines > 1) keyboardType = TextInputType.multiline;
//     } else if (type == "number") {
//       keyboardType = TextInputType.numberWithOptions(decimal: true);
//       inputFormatters = [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))];
//     }

//     textController ??= TextEditingController();
//     textController.text = initValue;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Label on top
//           Text(
//             label,
//             style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color.fromRGBO(55, 65, 81, 1)),
//           ),
//           const SizedBox(height: 5),

//           // Input field
//           // subtle shadow
//           TextFormField(
//             controller: textController,
//             maxLines: maxLines,
//             keyboardType: keyboardType,
//             inputFormatters: inputFormatters,
//             validator: validator,
//             onChanged: (text) {
//               if (type == "number") {
//                 text = text.replaceAll(',', '.');
//                 controller.obligation.set(key, num.tryParse(text) ?? 0);
//               } else {
//                 controller.obligation.set(key, text);
//               }
//             },
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(6),
//                 borderSide: const BorderSide(
//                     color: Color.fromRGBO(229, 231, 235, 1), width: 2),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:elh/models/Tranche.dart';
import 'package:elh/services/TrancheService.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactView.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/widgets/Upload_file_field.dart';

class AddObligationView extends StatefulWidget {
  final String type;
  final Obligation? obligation;

  AddObligationView(this.type, {this.obligation});

  @override
  AddObligationViewState createState() =>
      AddObligationViewState(type, obligation: obligation);
}

class AddObligationViewState extends State<AddObligationView> {
  final String type;
  final Obligation? obligation;
  final TrancheService _trancheService = TrancheService();

  AddObligationViewState(this.type, {this.obligation});
  List<Tranche> _tranches = [];

  @override
  void initState() {
    super.initState();
    if (obligation != null) {
      _loadTranches();
    }
  }

  Future<void> _loadTranches() async {
    final tranches = await _trancheService.getTranches(obligation!.id!);
    print(tranches[0].id);
    setState(() => _tranches = tranches);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddObligationController>.reactive(
      viewModelBuilder: () => AddObligationController(type, obligation),
      builder: (context, controller, child) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            title: Text(controller.title, style: headerTextWhite),
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
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: BBloader())
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    children: [
                      Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Intro Texts
                            // Center(
                            //   child: Text(
                            //     'Moi, ${controller.accordEntre()}',
                            //     style: const TextStyle(
                            //         fontFamily: 'inter',
                            //         fontSize: 14,
                            //         color: Color.fromRGBO(55, 65, 81, 1)),
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
                            UIHelper.verticalSpace(5),
                            Center(
                              child: Text(
                                "Moi ${controller.currentUserfullname}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Center(
                                child: Text(
                                  controller.getPersonTypeLabel(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Emprunteur Section

                            controller.showPersonSelectType
                                ? Column(
                                    children: [
                                      controller.showPersonFormDetails
                                          ? Column(
                                              children: [
                                                inputForm(controller,
                                                    'firstname', 'Prénom',
                                                    textController: controller
                                                        .firstnameTextController),
                                                inputForm(controller,
                                                    'lastname', 'Nom',
                                                    textController: controller
                                                        .lastNameTextController),
                                                inputForm(controller, 'tel',
                                                    'Téléphone',
                                                    textController: controller
                                                        .phoneTextController,
                                                    type:
                                                        'phone'), // phones are strings

                                                UIHelper.verticalSpace(5),
                                              ],
                                            )
                                          : personSelectionOptions(controller),
                                    ],
                                  )
                                : Center(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.searchContact(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            143, 151, 121, 1),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 2,
                                      ),
                                      child: Text(controller.getPersonneLabel(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),

                            const SizedBox(height: 10),

                            // Date Created
                            datePickerField(
                              controller: controller.dateStartController,
                              label: 'En Date du',
                              onConfirm: (date) => controller.updateDate(date),
                            ),
                            const SizedBox(height: 10),

                            // Montant prêté
                            inputForm(
                                controller, 'amount', controller.moneyLabel(),
                                type: 'number'),

                            const SizedBox(height: 10),
                            if (obligation?.remainingAmount != null)
                              inputForm(controller, 'amount', "Montant restant",
                                  type: 'number'),

                            const SizedBox(height: 10),

                            // Currency Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: controller.currency,
                              decoration: InputDecoration(
                                labelText: 'Devise',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: '\$', child: Text('\$')),
                                DropdownMenuItem(value: '€', child: Text('€')),
                                DropdownMenuItem(
                                    value: 'autre', child: Text('Autre')),
                              ],
                              onChanged: (value) {
                                controller.currency = value ?? '€';
                                controller.obligation
                                    .set('currency', controller.currency);
                              },
                            ),

                            const SizedBox(height: 10),

                            // Date limite de remboursement
                            datePickerField(
                              controller: controller.dateDueController,
                              label: 'Date limite de remboursement',
                              onConfirm: (date) =>
                                  controller.updateDueDate(date),
                            ),

                            const SizedBox(height: 10),

                            // Note (facultatif)
                            inputForm(controller, 'note', 'Note (facultative)',
                                maxLines: 3,
                                textController: controller.noteController),

                            const SizedBox(height: 20),
                            // Liste des tranches

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (obligation != null) ...[
                                  const Text(
                                    "Déjà rendu :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromRGBO(55, 65, 81, 1),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_tranches.isEmpty)
                                    const Text(
                                      "Aucune tranche pour le moment.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color.fromRGBO(55, 65, 81, 1),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: _tranches
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key + 1;
                                        final tranche = entry.value;
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: ListTile(
                                            title: Text("Tranche $i"),
                                            subtitle: Text(
                                              "${tranche.amount} ${obligation?.currency} le ${tranche.paidAt.toString()}",
                                            ),
                                            trailing: tranche.fileUrl != null
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      if (tranche.fileUrl !=
                                                              null &&
                                                          tranche.fileUrl!
                                                              .isNotEmpty) {
                                                        try {
                                                          final ref =
                                                              FirebaseStorage
                                                                  .instance
                                                                  .refFromURL(
                                                                      tranche
                                                                          .fileUrl!);
                                                          final downloadUrl =
                                                              await ref
                                                                  .getDownloadURL();

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12)),
                                                              child: SizedBox(
                                                                width: 300,
                                                                height: 420,
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Image
                                                                          .network(
                                                                        downloadUrl,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        loadingBuilder: (context, child, loadingProgress) => loadingProgress ==
                                                                                null
                                                                            ? child
                                                                            : const Center(child: CircularProgressIndicator()),
                                                                        errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) =>
                                                                            const Center(child: Text("Impossible de charger l'image")),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        // Modifier button
                                                                        TextButton
                                                                            .icon(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context); // Close current dialog
                                                                            _onModifyProof(context,
                                                                                tranche); // Handle modification
                                                                          },
                                                                          label:
                                                                              const Text(
                                                                            "Modifier",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black87,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        // Fermer button
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                          child:
                                                                              const Text(
                                                                            "Fermer",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black87,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        // Delete icon
                                                                        Positioned(
                                                                            top:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child: TextButton(
                                                                                child: Text("Supprimer"),
                                                                                onPressed: () {
                                                                                  Navigator.pop(context); // close current modify dialog
                                                                                  // show confirmation
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (ctx) => AlertDialog(
                                                                                      title: const Text("Supprimer la preuve"),
                                                                                      content: const Text("Voulez-vous vraiment supprimer cette preuve ?"),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () => Navigator.pop(ctx),
                                                                                          child: const Text("Annuler"),
                                                                                        ),
                                                                                        TextButton(
                                                                                          onPressed: () async {
                                                                                            Navigator.pop(ctx); // close confirmation dialog
                                                                                            // Call your delete method
                                                                                            // await widget.controller.deleteTrancheProof(tranche.id);
                                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                              const SnackBar(content: Text("Preuve supprimée.")),
                                                                                            );
                                                                                          },
                                                                                          child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                })),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  "Impossible de charger l'image"),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Pas de preuve disponible"),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                      "Voir preuve",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontFamily: 'inter',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 20),

                                  // Upload / Display proof image
                                  if (obligation?.fileUrl == null)
                                    UploadFileWidget(controller: controller)
                                  else
                                    FutureBuilder<String>(
                                      future: FirebaseStorage.instance
                                          .refFromURL(obligation!.fileUrl!)
                                          .getDownloadURL(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Text(
                                              'Erreur lors du chargement du fichier.');
                                        } else if (snapshot.hasData) {
                                          final downloadUrl = snapshot.data!;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Fichier actuel:',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                const SizedBox(height: 5),
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      child: Image.network(
                                                        downloadUrl,
                                                        height: 200,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          height: 100,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Center(
                                                              child: Icon(Icons
                                                                  .broken_image)),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: InkWell(
                                                        onTap: _deleteFile,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Save Button
                            ValueListenableBuilder<bool>(
                              valueListenable: controller.isFormValid,
                              builder: (context, isValid, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isValid
                                        ? () {
                                            controller.saveObligation();
                                          }
                                        : null, // disables button when false
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isValid
                                          ? primaryColor
                                          : Colors.grey[400],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Enregistrer",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            UIHelper.verticalSpace(20),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
      },
    );
  }

  // Person Selection Options
  Widget personSelectionOptions(AddObligationController controller) {
    return Column(
      children: [
        if (controller.canOpenPhoneContacts)
          Column(
            children: [
              GestureDetector(
                  onTap: () => controller.listPhoneContact(),
                  child: optionContainer('Rechercher un contact du téléphone')),
              UIHelper.verticalSpace(5),
              const Center(child: Text('OU')),
            ],
          ),
        GestureDetector(
            onTap: () => controller.searchContact(),
            child: optionContainer('Rechercher un contact Muslim Connect')),
        UIHelper.verticalSpace(5),
        const Center(child: Text('OU')),
        GestureDetector(
            onTap: () => controller.tglePersonFormDetails(),
            child: optionContainer('Créer un contact')),
      ],
    );
  }

  Widget optionContainer(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey, width: 2)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        const Icon(Icons.arrow_forward_ios, size: 18)
      ]),
    );
  }

  void openSelectContact(AddObligationController controller) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SelectContactView(
                showContact: true,
              )),
    );

    if (result == 'showForm') {
      controller.isEdit = true;
      controller
          .tglePersonFormDetails(); // now toggle the form in AddObligationController
    }
  }

  Widget inputForm(
    AddObligationController controller,
    String key,
    String label, {
    int maxLines = 1,
    String type = 'string',
    TextEditingController? textController,
  }) {
    String initValue = controller.obligation.get(key)?.toString() ?? '';
    TextInputType keyboardType = TextInputType.multiline;
    List<TextInputFormatter>? inputFormatters = [];

    // --- Définir le type de clavier ---
    if (type == "number") {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))];
    } else if (type == "phone" || key == "tel") {
      keyboardType = TextInputType.phone;
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    } else {
      keyboardType = TextInputType.text;
    }

    textController ??= TextEditingController(text: initValue);

    bool isOptional = label.toLowerCase().contains('(facultative)');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Label ---
          isOptional
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            label.replaceAll('(facultative)', '').trim() + ' ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(55, 65, 81, 1),
                        ),
                      ),
                      TextSpan(
                        text: '(facultative)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(55, 65, 81, 1),
                  ),
                ),
          const SizedBox(height: 5),

          // --- Input field ---
          TextFormField(
            controller: textController,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Champ obligatoire';

              if (type == 'string') return ValidatorHelpers.validateName(value);
              if (type == 'number' &&
                  num.tryParse(value.replaceAll(',', '.')) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              if (label == 'En date du' && (value.isEmpty)) {
                return 'La date de remboursement est obligatoire';
              }
              return null;
            },
            onChanged: (text) {
              switch (key) {
                case "firstname":
                  controller.obligation.firstname = text;
                  break;
                case "lastname":
                  controller.obligation.lastname = text;
                  break;
                case "tel":
                  controller.obligation.tel = text;
                  break;
                case "note":
                  controller.obligation.note = text;
                  break;
                case "amount":
                  controller.obligation.amount =
                      num.tryParse(text.replaceAll(',', '.')) ?? 0;
                  break;

                default:
                  controller.obligation.set(key, text);
                  break;
              }
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 231, 235, 1),
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Date Picker Field
  Widget datePickerField(
      {required TextEditingController controller,
      required String label,
      required Function(DateTime) onConfirm}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(55, 65, 81, 1))),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Material(
            elevation: 1,
            child: TextFormField(
              controller: controller,
              readOnly: true,
              onTap: () {
                picker.DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  onConfirm: (date) => onConfirm(date),
                  currentTime: DateTime.now(),
                  locale: picker.LocaleType.fr,
                );
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(229, 231, 235, 1), width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(229, 231, 235, 1), width: 2)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _deleteFile() {
    setState(() {
      obligation!.fileUrl = null;
    });
  }

  void _onModifyProof(BuildContext context, Tranche tranche) async {
    final ImagePicker picker = ImagePicker();

    Future<void> _pickAndUploadFile(ImageSource source) async {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      // Save or send new file path
      print("New file path: ${pickedFile.path}");

      // Call your upload API or update your controller
      // await widget.controller.updateTrancheProof(tranche.id, pickedFile.path);

      // Close the dialog after success
      Navigator.pop(context);

      // Optional: show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preuve modifiée avec succès.")),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickAndUploadFile(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choisir depuis la galerie"),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickAndUploadFile(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

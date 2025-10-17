// import 'package:elh/models/Relation.dart';
// import 'package:elh/models/userInfos.dart';
// import 'package:elh/ui/shared/BBLoader.dart';
// import 'package:elh/ui/shared/text_styles.dart';
// import 'package:elh/ui/shared/ui_helpers.dart';
// import 'package:elh/ui/views/common/userThumb.dart';
// import 'package:elh/ui/views/modules/Relation/SelectContactController.dart';
// import 'package:flutter/material.dart';
// import 'package:elh/common/theme.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:stacked/stacked.dart';

// class SelectContactView extends StatefulWidget {
//   @override
//   SelectContactViewState createState() => SelectContactViewState();
// }

// class SelectContactViewState extends State<SelectContactView> {
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<SelectContactController>.reactive(
//         builder: (context, controller, child) => Scaffold(
//             backgroundColor: bgLightV2,
//             appBar: AppBar(
//               title: Text("Add Emprunter", style: headerTextWhite),
//               iconTheme: new IconThemeData(color: Colors.white),
//               backgroundColor: primaryColor,
//               actions: [],
//             ),
//             body: controller.isLoading
//                 ? Center(child: BBloader())
//                 : SafeArea(
//                     child: RefreshIndicator(
//                       onRefresh: controller.refreshDatas,
//                       child: ListView(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                         children: relations(controller),
//                       ),
//                     ),
//                   )),
//         viewModelBuilder: () => SelectContactController());
//   }

//   List<Widget> relations(SelectContactController controller) {
//     List<Widget> relationList = [];
//     int nbResults = controller.relations.length;
//     int index = 0;
//     if (controller.relations.length > 0) {
//       controller.relations.forEach((relation) {
//         relationList.add(_userInfos(controller, relation, true));
//       });
//     }
//     return relationList;
//   }

//   _userInfos(SelectContactController controller, relation, toValidate) {
//     UserInfos user = relation.user;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 userThumbDirect(
//                     user.photo, "${user.firstname!.substring(0, 2)}", 20.0),
//                 UIHelper.horizontalSpace(10),
//                 Expanded(
//                     child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.fullname,
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 )),
//                 Container(
//                   width: 90,
//                   alignment: Alignment.topRight,
//                   child: _status(controller, relation, toValidate),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _status(SelectContactController controller, Relation relation, toValidate) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5),
//       child: GestureDetector(
//         onTap: () {
//           controller.selectRelation(relation);
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [Icon(MdiIcons.arrowRight, color: fontDark, size: 22)],
//         ),
//       ),
//     );
//   }
// }
import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactView.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SelectContactView extends StatefulWidget {
  final bool showContact;

  const SelectContactView({
    Key? key,
    this.showContact = false,
  }) : super(key: key);
  @override
  SelectContactViewState createState() => SelectContactViewState();
}

class SelectContactViewState extends State<SelectContactView> {
  String searchQuery = ""; // Define and initialize _searchQuery

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectContactController>.reactive(
      viewModelBuilder: () => SelectContactController(),
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLightV2,
        appBar: AppBar(
          title: Text(
            widget.showContact != true
                ? "Partage avec un membre mc"
                : "Ajouter un contact",
            style: headerTextWhite,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
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
        body: controller.isLoading
            ? Center(child: BBloader())
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.refreshDatas,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    children: [
                      // Top rows
                      if (widget.showContact) ...[
                        if (controller.canOpenPhoneContacts)
                          _topRow(
                            icon: Icons.search,
                            text: "Rechercher un contact du répertoire",
                            onTap: () async {
                              final value = await NavigationService()
                                  .navigateWithTransition(
                                ListPhoneContactView(),
                                transitionStyle: Transition.downToUp,
                                duration: const Duration(milliseconds: 300),
                              );

                              if (value != null) {
                                UserInfos user;
                                if (value is Contact) {
                                  user = UserInfos(
                                    firstname: value.name.first,
                                    lastname: value.name.last,
                                    phone: value.phones.isNotEmpty
                                        ? value.phones.first.number
                                        : '',
                                    id: null,
                                    fullname: '',
                                    phonePrefix: '',
                                    city: '',
                                    photo: '',
                                  );
                                } else {
                                  user = value;
                                }

                                Navigator.of(context).pop(user);
                              }
                            },
                          ),
                        const SizedBox(height: 10),
                        _topRow(
                          icon: Icons.add,
                          text: "Créer un contact",
                          onTap: () {
                            Navigator.of(context).pop('showForm');
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Person form (if visible)
                      if (controller.isPersonFormVisible)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              TextField(
                                controller: controller.firstnameTextController,
                                decoration: InputDecoration(
                                  labelText: 'Prénom',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              TextField(
                                controller: controller.lastNameTextController,
                                decoration: InputDecoration(
                                  labelText: 'Nom',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              TextField(
                                controller: controller.phoneTextController,
                                decoration: InputDecoration(
                                  labelText: 'Téléphone',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      // Relations list title
                      Text(
                        "Ma communauté",
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(55, 65, 81, 1),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Relations list
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher un contact",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery =
                                value; // _searchQuery is a String in your State
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      // Relations list
                      ...relations(controller, searchQuery),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Reusable top row widget
  Widget _topRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                selectionColor: Color.fromRGBO(55, 65, 81, 1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(55, 65, 81, 1),
                ),
              ),
            ),
            Icon(MdiIcons.arrowRight, color: fontDark, size: 22),
          ],
        ),
      ),
    );
  }

// Relations list with search filter
  List<Widget> relations(
      SelectContactController controller, String searchQuery) {
    List<Widget> relationList = [];

    // Filter relations based on the search query
    final filteredRelations = controller.relations.where((relation) {
      final fullName =
          "${relation.user.firstname} ${relation.user.lastname}".toLowerCase();
      return fullName.contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredRelations.isNotEmpty) {
      filteredRelations.forEach((relation) {
        relationList.add(
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: _userInfos(controller, relation, true),
          ),
        );
      });
    } else {
      relationList.add(
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Aucun contact trouvé",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return relationList;
  }

  // // Relations list
  // List<Widget> relations(SelectContactController controller) {
  //   List<Widget> relationList = [];
  //   if (controller.relations.isNotEmpty) {
  //     controller.relations.forEach((relation) {
  //       relationList.add(
  //         Container(
  //           margin: EdgeInsets.only(bottom: 10),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(2),
  //             border: Border.all(
  //               color: Color.fromRGBO(229, 231, 235, 1),
  //               width: 2,
  //             ),
  //           ),
  //           child: _userInfos(controller, relation, true),
  //         ),
  //       );
  //     });
  //   }
  //   return relationList;
  // }

  Widget _userInfos(
      SelectContactController controller, Relation relation, bool toValidate) {
    UserInfos user = relation.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                // Profile picture with circular border
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromRGBO(229, 231, 235, 1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: userThumbDirect(
                        user.photo, "${user.firstname!.substring(0, 2)}", 20.0),
                  ),
                ),
                UIHelper.horizontalSpace(20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromRGBO(55, 65, 81, 1)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  alignment: Alignment.topRight,
                  child: _status(controller, relation, toValidate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(
      SelectContactController controller, Relation relation, bool toValidate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () => controller.selectRelation(relation),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Icon(MdiIcons.arrowRight, color: fontDark, size: 22)],
        ),
      ),
    );
  }
}

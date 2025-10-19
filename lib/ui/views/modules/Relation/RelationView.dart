import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Relation/RelationController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class RelationView extends StatefulWidget {
  @override
  RelationViewState createState() => RelationViewState();
}

class RelationViewState extends State<RelationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RelationController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Ma communauté ${controller.nbRelationsLabel()}',
                  style: headerTextWhite),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              actions: [],
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
                controller.addRelation();
              },
              label: const Text(
                'Ajouter un contact',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 25),
              backgroundColor: primaryColor,
            ),
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                      onRefresh: controller.refreshDatas,
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        children: relations(controller),
                      ),
                    ),
                  )),
        viewModelBuilder: () => RelationController());
  }

  List<Widget> relations(RelationController controller) {
    List<Widget> relationList = [];
    int nbResults = controller.relations.length;
    int index = 0;
    if (nbResults > 15) {
      relationList.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Text("Rechercher un membre de ma communauté",
                style: labelSmallStyle),
            UIHelper.verticalSpace(5),
            TextField(
              controller: controller.searchInputController,
              onChanged: (String value) async {
                controller.setSearch(value);
              },
              onSubmitted: (String value) async {
                controller.searchUser();
              },
              decoration: InputDecoration(
                hintStyle: TextStyle(color: fontGrey),
                enabledBorder: InputBorder.none,
                suffixIcon: controller.isLoading
                    ? Container(width: 0)
                    : controller.searchTerm.length > 0
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: fontGrey,
                            ),
                            onPressed: () {
                              controller.clearSearch();
                            },
                          )
                        : Icon(Icons.search, color: fontGrey, size: 20),
                hintText: 'Nom ou prénom ...',
                border: InputBorder.none,
              ),
            ),
            controller.showErrorText
                ? Center(
                    child: Text(
                        'La recherche doit contenir au moins 4 caractères !'),
                  )
                : Container(),
            UIHelper.verticalSpace(20),
          ],
        ),
      ));
    }

    if (controller.relationsToValidate.length > 0) {
      relationList.add(Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text('Contacts à valider')));
      controller.relationsToValidate.forEach((relation) {
        relationList.add(_userInfos(controller, relation, true));
      });
      relationList.add(UIHelper.verticalSpace(20));
    }
    if (controller.relations.length > 0) {
      controller.relations.forEach((relation) {
        relationList.add(_userInfos(controller, relation, true));
      });
    }
    relationList.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Center(
          child: Text(textCommu,
              style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
        )));

    return relationList;
  }

  _userInfos(RelationController controller, relation, toValidate) {
    UserInfos user = relation.user;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                userThumbDirect(
                    user.photo, "${user.firstname.substring(0, 2)}", 20.0),
                UIHelper.horizontalSpace(10),
                Expanded(
                    child: Row(
                  children: [
                    Text("${user.firstname} ${user.lastname}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                Container(
                  width: 90,
                  alignment: Alignment.topRight,
                  child: _status(controller, relation, toValidate),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _status(RelationController controller, Relation relation, toValidate) {
    if (relation.status == "active") {
      //
      return PopupMenuButton(
        elevation: 3,
        offset: Offset(30, 35),
        child: Icon(MdiIcons.dotsVertical, color: Colors.black),
        itemBuilder: (BuildContext bc) => [
          // PopupMenuItem(
          //     child: Row(
          //       children: [
          //         SizedBox(
          //           width: 25,
          //           child: FittedBox(
          //               fit: BoxFit.scaleDown,
          //               alignment: Alignment.center,
          //               child: SvgPicture.asset(
          //                 'assets/icon/bubbles.svg',
          //                 color: fontGreyDark,
          //                 height: 22,
          //                 width: 22.0,
          //                 // fit: BoxFit.fill,
          //               )
          //           ),
          //         ),
          //         UIHelper.horizontalSpace(8),
          //         Text("Discuter", style: TextStyle(fontSize: 14)),
          //       ],
          //     ),
          //     value: "chat"
          // ),
          PopupMenuItem(
              child: Row(
                children: [
                  Icon(
                    MdiIcons.trashCanOutline,
                    color: fontGreyDark,
                  ),
                  UIHelper.horizontalSpace(8),
                  Text("Supprimer ce contact", style: TextStyle(fontSize: 14)),
                ],
              ),
              value: "blockcontact")
        ],
        onCanceled: () {},
        onSelected: (value) {
          if (value == 'blockcontact') {
            controller.blockRelation(relation);
          } else if (value == 'chat') {
            controller.chatWithHim(relation);
          }
        },
      );
    } else if (relation.status == "pending" && toValidate) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              controller.validateRelation(relation, true);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Valider',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
          UIHelper.horizontalSpace(5),
          GestureDetector(
            onTap: () {
              controller.validateRelation(relation, false);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(MdiIcons.deleteOutline, size: 14, color: errorColor),
            ),
          )
        ],
      );
    } else if (relation.status == "pending") {
      return Tooltip(
        verticalOffset: 5,
        message: "En attente",
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.pending_outlined,
            color: fontGrey,
          ),
        ),
      );
    }
  }
}

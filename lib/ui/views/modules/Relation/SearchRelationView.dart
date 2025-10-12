import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Relation/SearchRelationController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class SearchRelationView extends StatefulWidget {
  String backview = 'chat';
  SearchRelationView(this.backview);
  @override
  SearchRelationViewState createState() => SearchRelationViewState(backview);
}

class SearchRelationViewState extends State<SearchRelationView> {
  String backview = 'chat';
  SearchRelationViewState(this.backview);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchRelationController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Rechercher un contact', style: headerTextWhite),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () async {
                    Navigator.of(context).pop(
                        controller.updateListcontacts ? 'updateList' : null);
                  }),
              actions: [],
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        color: bgLight,
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: TextField(
                          controller: controller.searchTextController,
                          maxLines: 1,
                          decoration:
                              InputDecoration(labelText: "Email ou téléphone"),
                          onSubmitted: (String value) async {
                            controller.searchRelations();
                          },
                          // decoration: decoration.app,
                        ),
                      ),
                      Positioned(
                        right: 35,
                        top: 25,
                        child: Container(
                            color: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                controller.searchRelations();
                              },
                              icon: Icon(MdiIcons.accountSearch),
                            )),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(top: 5, left: 20, right: 30),
                    child: GestureDetector(
                      onTap: () {
                        controller.listPhoneContact();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Rechercher dans mon répertoire',
                              style: TextStyle(
                                  color: fontDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(15),
                  controller.showErrorText
                      ? Center(
                          child: Text('Recherche non valide !'),
                        )
                      : Container(),
                  controller.showInfosSearch
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Center(
                              child: Text(textCommu,
                                  style: TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center)))
                      : Container(),
                  Expanded(
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      children: relations(controller),
                    ),
                  ),
                ],
              ),
            )),
        viewModelBuilder: () => SearchRelationController(backview));
  }

  List<Widget> relations(SearchRelationController controller) {
    if (controller.isLoading) {
      return [Center(child: UIHelper.lineLoaders(3, 20))];
    }
    List<Widget> relationList = [];
    int nbResults = controller.relations.length;
    int index = 0;
    if (nbResults == 0 && controller.hasSearchRelation) {
      relationList.add(Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text('Contact introuvable', style: inTitleStyle),
            UIHelper.verticalSpace(5),
            controller.searchBy == 'phone'
                ? RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 15),
                      children: [
                        TextSpan(
                            text:
                                'Veuillez essayer via son e-mail ou l’inviter à rejoindre '),
                        TextSpan(
                          text: 'Muslim Connect.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Text(
                          'Inviter ${controller.searchTextController.text} à rejoindre Muslim Connect ?'),
                      controller.isInviting
                          ? BBloader()
                          : GestureDetector(
                              onTap: () {
                                controller.sendInvitation();
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5, left: 15, right: 15, bottom: 8),
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  'Envoyer une invitation',
                                  style: headerTextWhite,
                                ),
                              ),
                            )
                    ],
                  ),
          ],
        ),
      ));
    }
    controller.relations.forEach((relation) {
      UserInfos user = relation.user;
      relationList.add(Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  userThumbDirect(
                      user.photo, "${user.firstname!.substring(0, 2)}", 20.0),
                  UIHelper.horizontalSpace(10),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstname} ${user.lastname}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
                  Container(
                    width: 70,
                    alignment: Alignment.topRight,
                    child: _status(controller, relation),
                  )
                ],
              ),
            ],
          ),
        ),
      ));
      index++;
      if (index < nbResults) {
        relationList.add(Container(
          height: 1,
          color: Colors.black12,
        ));
      }
    });
    return relationList;
  }

  _status(SearchRelationController controller, Relation relation) {
    if (controller.isAddingRelationId == relation.user.id) {
      return BBloader();
    }
    if (relation.status == 'active') {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              MdiIcons.check,
              color: successColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.chatWithHim(relation);
            },
            child: SizedBox(
              width: 25,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icon/bubbles.svg',
                    color: fontGreyDark,
                    height: 24,
                    width: 24.0,
                    // fit: BoxFit.fill,
                  )),
            ),
          )
        ],
      );
    } else if (relation.status == "pending") {
      return Tooltip(
        verticalOffset: 5,
        message: "En attente d'approbation",
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.pending_outlined,
            color: fontGrey,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          controller.addRelation(relation);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            'Ajouter',
            style: TextStyle(color: primaryColor),
          ),
        ),
      );
    }
  }
}

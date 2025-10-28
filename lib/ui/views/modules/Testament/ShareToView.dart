import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Testament/ShareToController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class ShareToView extends StatefulWidget {
  @override
  ShareToViewState createState() => ShareToViewState();
}

class ShareToViewState extends State<ShareToView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ShareToController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Partager avec mes proches', style: headerTextWhite),
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
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
                controller.goToContact();
              },
              label: const Text(
                'Ajouter un proche',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon: Icon(MdiIcons.plus, color: Colors.white, size: 25),
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
        viewModelBuilder: () => ShareToController());
  }

  List<Widget> relations(ShareToController controller) {
    List<Widget> relationList = [];
    int nbResults = controller.relations.length;
    int index = 0;
    if (controller.relations.length > 0) {
      controller.relations.forEach((relation) {
        relationList.add(_userInfos(controller, relation));
      });
    } else {
      relationList.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text(
              "Tu n'as aucun contact, cliquez sur 'Mes contacts' et ajoutez vos connaissances.")));
    }
    relationList.add(UIHelper.verticalSpace(15));

    return relationList;
  }

  _userInfos(ShareToController controller, relation) {
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
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.firstname,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
                Container(
                    width: 180,
                    alignment: Alignment.topRight,
                    child: ValueListenableBuilder<int>(
                      builder: (BuildContext context, int relationChangeId,
                          Widget? child) {
                        return relation.id == relationChangeId
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  BBloader(),
                                ],
                              )
                            : _status(controller, relation);
                      },
                      valueListenable: controller.relationChangeId,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  _status(ShareToController controller, Relation relation) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          relation.shareTestament
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Partagé",
                        style: TextStyle(
                            color: successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    UIHelper.horizontalSpace(3),
                    Icon(MdiIcons.check, color: successColor, size: 20),
                    UIHelper.horizontalSpace(10)
                  ],
                )
              : Container(),
          PopupMenuButton(
            elevation: 3,
            offset: Offset(30, 35),
            child: Icon(MdiIcons.dotsVertical, color: Colors.black),
            itemBuilder: (BuildContext bc) => [
              PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(!relation.shareTestament
                          ? MdiIcons.shareVariantOutline
                          : MdiIcons.close),
                      UIHelper.horizontalSpace(8),
                      Text(relation.shareTestament
                          ? "Ne plus partager"
                          : "Partager"),
                    ],
                  ),
                  value: "shareTO"),
            ],
            onCanceled: () {},
            onSelected: (value) {
              controller.validateShareTo(relation, !relation.shareTestament);
            },
          )
        ],
      ),
    );
  }
}

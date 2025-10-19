import 'package:elh/models/Relation.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Salat/SharetoController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:stacked/stacked.dart';

class SharetoView extends StatefulWidget {
  Salat salat;
  SharetoView(this.salat);
  @override
  SharetoViewState createState() => SharetoViewState(this.salat);
}

class SharetoViewState extends State<SharetoView> {
  Salat salat;
  SharetoViewState(this.salat);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SharetoController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text(
                  'Partager salât : ${salat.firstname}  ${salat.lastname} ',
                  style: headerTextWhite),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
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
        viewModelBuilder: () => SharetoController(this.salat));
  }

  List<Widget> relations(SharetoController controller) {
    List<Widget> relationList = [];
    relationList.add(Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('Ma communauté', style: inTitleStyle)));

    if (controller.relations.length > 0) {
      controller.relations.forEach((relation) {
        relationList.add(_userInfos(controller, relation));
      });
    } else {
      relationList.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          child: Center(
            child: Text("Aucun membre dans votre communauté",
                style: noResultStyle, textAlign: TextAlign.center),
          )));
      relationList.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          child: Center(
            child: Text(textCommu,
                style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
          )));
    }
    return relationList;
  }

  _userInfos(SharetoController controller, relation) {
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
                  width: 90,
                  alignment: Alignment.topRight,
                  child: _status(controller, relation),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _status(SharetoController controller, Relation relation) {
    if (controller.currentRelationLoading == relation.id) {
      return UIHelper.lineLoaders(1, 3);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            controller.shareSalatToContact(relation);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: relation.active
                ? Icon(Icons.check, color: primaryColor)
                : Text(
                    'Partager',
                    style: TextStyle(color: primaryColor),
                  ),
          ),
        )
      ],
    );
  }
}

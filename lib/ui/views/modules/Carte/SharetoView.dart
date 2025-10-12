import 'package:elh/models/Relation.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Carte/SharetoController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class SharetoView extends StatefulWidget {
  Carte carte;
  SharetoView(this.carte);
  @override
  SharetoViewState createState() => SharetoViewState(this.carte);
}

class SharetoViewState extends State<SharetoView> {
  Carte carte;
  SharetoViewState(this.carte);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SharetoController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Partager carte : ${carte.typeLabel}', style: headerTextWhite),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: primaryColor,
              actions: [
              ],
            ),
            body: controller.isLoading ? Center(child: BBloader()) : SafeArea(
                child:  RefreshIndicator(
                  onRefresh: controller.refreshDatas,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    children: relations(controller),
                  ),
                ),
            )),
        viewModelBuilder: () => SharetoController(this.carte)
    );
  }

  List<Widget> relations(SharetoController controller) {
    List<Widget> relationList = [];
    if(controller.relations.length > 0) {
      relationList.add(
          Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Text('Ma communauté'))
      );
      controller.relations.forEach((relation) {
        relationList.add(_userInfos(controller, relation));
      });
    }
    return relationList;
  }

  _userInfos(SharetoController controller, relation) {
    UserInfos user = relation.user;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical:5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  userThumbDirect(user.photo, "${user.firstname!.substring(0,2)}",  20.0),
                  UIHelper.horizontalSpace(10),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.firstname, style: TextStyle(fontWeight: FontWeight.bold),),
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
    if(controller.currentRelationLoading == relation.id) {
      return UIHelper.lineLoaders(1, 3);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            controller.shareCarteToContact(relation);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: relation.active ? Icon(Icons.check, color: primaryColor) :
            Row(
              children: [
                Text('Partager', style: TextStyle(color: fontDark, fontWeight: FontWeight.bold),),
                UIHelper.horizontalSpace(5),
                Icon(Icons.arrow_forward, color: fontDark, size: 15,)
              ],
            )
          ),
        )
      ],
    );
  }
}
import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class SelectContactView extends StatefulWidget {
  @override
  SelectContactViewState createState() => SelectContactViewState();
}

class SelectContactViewState extends State<SelectContactView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectContactController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Ma communauté ${controller.nbRelationsLabel()}',
                  style: headerTextWhite),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: primaryColor,
              actions: [],
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
        viewModelBuilder: () => SelectContactController());
  }

  List<Widget> relations(SelectContactController controller) {
    List<Widget> relationList = [];
    int nbResults = controller.relations.length;
    int index = 0;
    if (controller.relations.length > 0) {
      controller.relations.forEach((relation) {
        relationList.add(_userInfos(controller, relation, true));
      });
    }
    return relationList;
  }

  _userInfos(SelectContactController controller, relation, toValidate) {
    UserInfos user = relation.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                      user.fullname,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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

  _status(SelectContactController controller, Relation relation, toValidate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          controller.selectRelation(relation);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Icon(MdiIcons.arrowRight, color: fontDark, size: 22)],
        ),
      ),
    );
  }
}

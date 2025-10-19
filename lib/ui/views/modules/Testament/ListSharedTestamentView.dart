import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/views/modules/Testament/ListSharedTestamentController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class ListSharedTestamentView extends StatefulWidget {
  @override
  ListSharedTestamentViewState createState() => ListSharedTestamentViewState();
}

class ListSharedTestamentViewState extends State<ListSharedTestamentView> {
  ListSharedTestamentViewState();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListSharedTestamentController>.reactive(
        viewModelBuilder: () => ListSharedTestamentController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Testaments partagés", style: headerTextWhite),
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
            extendBody: true,
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                      onRefresh: controller.refreshDatas,
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        children: otherTestaments(controller),
                      ),
                    ),
                  )));
  }

  otherTestaments(ListSharedTestamentController controller) {
    List<Widget> otherTestaments = [];
    controller.othersTestaments.forEach((testament) {
      otherTestaments.add(GestureDetector(
        onTap: () {
          controller.gotToOtherTestament(testament);
        },
        child: Card(
            elevation: 0,
            color: const Color(0xFFFFFFFF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 9,
                      child: Text('Testament de ${testament.from}',
                          style: new TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(MdiIcons.arrowRightCircleOutline)],
                    ),
                  )
                ],
              ),
            )),
      ));
    });
    return otherTestaments;
  }
}

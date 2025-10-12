import 'package:elh/common/elh_icons.dart';
import 'package:elh/models/PompeDemand.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Pompe/DemandPompeController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:stacked/stacked.dart';

class DemandPompeView extends StatefulWidget {
  @override
  DemandPompeViewState createState() => DemandPompeViewState();
}

class DemandPompeViewState extends State<DemandPompeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DemandPompeController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Mes demandes', style: headerTextWhite),
              backgroundColor: Colors.transparent,
              iconTheme: new IconThemeData(color: Colors.white),
              elevation: 0,
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
                    child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        controller: controller.scrollController,
                        children: demands(controller)),
                    onRefresh: controller.refreshData,
                  ))),
        viewModelBuilder: () => DemandPompeController());
  }

  List<Widget> demands(DemandPompeController controller) {
    List<Widget> demands = [];
    controller.demands.forEach((demand) {
      demands.add(demandWidget(controller, demand));
    });
    return demands;
  }

  Widget demandWidget(DemandPompeController controller, PompeDemand demand) {
    Color color = Color(0xFF1198EF);
    if (demand.status == 'accepted') {
      color = Color(0xFF72A17E);
    } else if (demand.status == 'rejected') {
      color = Color(0xFFEA3232);
    }
    return Card(
        elevation: 1,
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demande du ${demand.dateString}',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
              UIHelper.verticalSpace(5),
              Text('Décès de ${demand.dece.firstname} ${demand.dece.lastname}',
                  style: textDescription),
              UIHelper.verticalSpace(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder<int>(
                    builder:
                        (BuildContext context, int isSendingId, Widget? child) {
                      return isSendingId == demand.id
                          ? BBloader()
                          : Center(
                              child: GestureDetector(
                              child: Row(
                                children: [
                                  Text(demand.statusLabel,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                                  UIHelper.horizontalSpace(5),
                                  demand.status != 'rejected'
                                      ? Icon(Icons.mail_outline,
                                          size: 20, color: fontGrey)
                                      : Container()
                                ],
                              ),
                              onTap: () {
                                if (demand.status == 'canDemand') {
                                  controller.pompeAcceptDemand(demand);
                                } else if (demand.status == 'accepted') {
                                  //go to chat
                                  controller.goChat(demand);
                                }
                              },
                            ));
                    },
                    valueListenable: controller.isSendingId,
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

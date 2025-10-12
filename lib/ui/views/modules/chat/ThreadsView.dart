import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/chat/ThreadsController.dart';
import 'package:stacked/stacked.dart';

class ThreadsView extends StatefulWidget {
  const ThreadsView({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  ThreadsViewState createState() => ThreadsViewState();
}

class ThreadsViewState extends State<ThreadsView>
    with TickerProviderStateMixin {
  bool refresh = false;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ThreadsController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title: Text('Discussions', style: headerTextWhite),
              backgroundColor: Colors.transparent,
              iconTheme: new IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.goToAddthread();
                  },
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
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
                'Ajouter un contact',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Karla'),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 25),
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
                      children: [
                        _threadList(context, controller, controller.threads),
                        UIHelper.verticalSpace(15)
                      ],
                    ),
                    onRefresh: controller.refreshData,
                  ))),
        viewModelBuilder: () => ThreadsController());
  }
}

Widget _threadList(BuildContext context, controller, List<Thread> threads) {
  List<Widget> list = [];
  if (threads.isEmpty) {
    list.add(Column(
      children: [
        Center(
            child: Text(
          "Pour discuter tu dois d'abord créer ta communauté en ajoutant des contacts",
          textAlign: TextAlign.center,
        )),
        UIHelper.verticalSpace(15),
        GestureDetector(
          onTap: () {
            controller.navigateCommunaute();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
                color: primaryColor, borderRadius: BorderRadius.circular(15)),
            child: Text(
              "Créer ma communauté",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    ));
  }
  threads.forEach((Thread thread) {
    list.add(GestureDetector(
      onTap: () {
        controller.navigateToChat(thread);
      },
      child: Card(
          elevation: 0.0,
          color: const Color(0xFFFFFFFF),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      userThumbIconEmpty(
                          thread.image,
                          40.0,
                          thread.type == 'simple'
                              ? Icons.person_outline_outlined
                              : Icons.group_outlined,
                          16.0),
                      UIHelper.dotNotif(thread.hasMessage, 11.0, 4.0),
                    ],
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thread.name,
                            style: new TextStyle(fontWeight: FontWeight.bold)),
                        thread.type == 'group'
                            ? Text(thread.nbParticpants,
                                style: new TextStyle(
                                    color: fontGrey, fontSize: 12))
                            : Container(),
                        Text(thread.lastMessage,
                            style: new TextStyle(
                                color: fontGreyLight, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(thread.lastUpdate,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, color: fontGrey)),
                      UIHelper.horizontalSpace(3),
                    ],
                  ),
                )
              ],
            ),
          )),
    ));
  });

  return RefreshIndicator(
      child: Column(children: list), onRefresh: controller.refreshData);
}

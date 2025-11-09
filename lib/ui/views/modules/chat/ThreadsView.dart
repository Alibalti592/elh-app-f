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
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_outlined,
                  color: Colors.white),
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
              fontFamily: 'Karla',
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 25),
        ),
        body: controller.isLoading
            ? const Center(child: BBloader())
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.refreshData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    controller: controller.scrollController,
                    children: [
                      _threadList(context, controller, controller.threads),
                      UIHelper.verticalSpace(15),
                    ],
                  ),
                ),
              ),
      ),
      viewModelBuilder: () => ThreadsController(),
    );
  }
}

Widget _threadList(BuildContext context, controller, List<Thread> threads) {
  List<Widget> list = [];
  if (threads.isEmpty) {
    list.add(
      Column(
        children: [
          const Center(
            child: Text(
              "Pour discuter tu dois d'abord créer ta communauté en ajoutant des contacts",
              textAlign: TextAlign.center,
            ),
          ),
          UIHelper.verticalSpace(15),
          GestureDetector(
            onTap: () {
              controller.navigateCommunaute();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Créer ma communauté",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  for (final Thread thread in threads) {
    list.add(
      GestureDetector(
        onTap: () {
          controller.navigateToChat(thread);
        },
        child: Card(
          // ★ Small shadow
          elevation: 2.0,
          shadowColor: Colors.black12,
          color: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.symmetric(vertical: 6),
          // ★ Rounded border with subtle color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: primaryColor.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
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
                        16.0,
                      ),
                      UIHelper.dotNotif(thread.hasMessage, 11.0, 4.0),
                    ],
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          thread.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Participants (for groups)
                        if (thread.type == 'group')
                          Text(
                            thread.nbParticpants,
                            style: TextStyle(color: fontGrey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // ★ Last message: bigger + dark gray
                        Text(
                          thread.lastMessage,
                          style: TextStyle(
                            fontSize: 14, // bigger
                            color: Colors.grey[800], // dark gray
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        thread.lastUpdate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fontGrey,
                        ),
                      ),
                      UIHelper.horizontalSpace(3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Keep your inner RefreshIndicator if you rely on it elsewhere
  return RefreshIndicator(
    onRefresh: controller.refreshData,
    child: Column(children: list),
  );
}

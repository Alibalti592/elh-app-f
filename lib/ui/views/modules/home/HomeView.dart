import 'package:elh/models/AppNotification.dart';
import 'package:elh/services/NotificationService.dart';
import 'package:elh/ui/views/modules/chat/ThreadsView.dart';
import 'package:flutter/material.dart';

import 'package:stacked/stacked.dart';
import 'package:badges/badges.dart' as badges;
import 'package:elh/ui/views/modules/home/HomeController.dart';
import 'package:elh/ui/views/modules/home/DashboardController.dart';
import 'package:elh/ui/views/modules/home/DashboardView.dart';
import 'package:elh/ui/views/modules/home/PageNavigationView.dart';
import 'package:elh/ui/views/layout/drawer.dart';
import 'package:elh/ui/views/common/BBottombar/CurvedNavigationBar.dart';
import 'package:elh/ui/views/common/BBottombar/CurvedNavigationBarItem.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/common/elh_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:elh/services/TrancheNotificationHandler.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  List<AppNotification> _notifications = [];

  late final int initialIndex;
  final DashboardController dashboardController = DashboardController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initialIndex = widget.initialIndex;
    _loadNotifications();
  }

  void _loadNotifications() async {
    final notifications = await NotificationService().fetchNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeController>.reactive(
      viewModelBuilder: () => HomeController(),
      builder: (context, controller, child) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                key: scaffoldKey,
                backgroundColor: bgLight,
                appBar: _topBar(controller, initialIndex),
                bottomNavigationBar:
                    SafeArea(child: bottomBar(controller, initialIndex)),
                drawer: BBNavigationDrawer(),
                extendBody: true,
                body: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller.pageController,
                  onPageChanged: (pageNum) {
                    if (pageNum == 0) controller.refreshDashboard();
                  },
                  children: [
                    DashboardView(controller: dashboardController),
                    PageNavigationView('dette'),
                    PageNavigationView('deuil'),
                    PageNavigationView('pray'),
                    PageNavigationView('don'),
                  ],
                ),
              ),
              const TrancheNotificationHandler(),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder<List<AppNotification>>(
            future: NotificationService()
                .fetchNotifications(), // Fetch latest notifications
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text("Erreur lors du chargement des notifications"),
                );
              } else {
                List<AppNotification> pending =
                    snapshot.data!.where((n) => n.status == 'pending').toList();

                if (pending.isEmpty) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Text("Aucune notification en attente"),
                  );
                }

                return StatefulBuilder(
                  builder: (context, setStateModal) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final notif = pending[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(notif.title),
                            subtitle: Text(notif.message),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    bool ok = await NotificationService()
                                        .respondNotif(notif.id, 'accept');
                                    if (ok) {
                                      setStateModal(() {
                                        notif.status = 'accept';
                                        pending.removeAt(index);
                                      });
                                      setState(() {
                                        _notifications =
                                            List.from(_notifications);
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    bool ok = await NotificationService()
                                        .respondNotif(notif.id, 'decline');
                                    if (ok) {
                                      setStateModal(() {
                                        notif.status = 'decline';
                                        pending.removeAt(index);
                                      });
                                      setState(() {
                                        _notifications =
                                            List.from(_notifications);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  _topBar(HomeController controller, int initialIndex) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: ValueListenableBuilder<int>(
        valueListenable: controller.pageIndex,
        builder: (context, currentIndex, child) {
          final pageKeyMap = {
            0: 'home',
            1: 'dette',
            2: 'deuil',
            3: 'pray',
            4: 'don',
          };
          String pageKey = pageKeyMap[currentIndex] ?? 'home';
          String title = 'Muslim Connect';

          List<Color> gradientColors = [
            Color.fromRGBO(220, 198, 169, 1.0),
            Color.fromRGBO(143, 151, 121, 1.0),
          ];

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              leadingWidth: controller.appBarLeadinWidth.value,
              toolbarHeight: 60,
              titleSpacing: 0,
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: fontGreyDark),

              // Drawer button
              leading: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                  icon: Icon(MdiIcons.menu, color: Colors.black, size: 24),
                ),
              ),

              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        // Dynamic subtitle on home page
                        if (pageKey == 'home')
                          ValueListenableBuilder<String?>(
                            valueListenable: controller.userName,
                            builder: (context, name, _) {
                              String firstName = '';
                              if (name != null && name.isNotEmpty) {
                                firstName = name.split(' ')[0];
                              }
                              return Text(
                                'Assalem Alaykoum, ${firstName}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: [
                IconButton(
                  icon: badges.Badge(
                    showBadge: _notifications
                        .any((n) => n.status == 'pending'), // check dynamically
                    badgeContent: Text(
                      '${_notifications.where((n) => n.status == 'pending').length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white, // icon color
                    ),
                  ),
                  onPressed: () => _showNotificationsModal(context),
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ThreadsView(title: "Mes Discussions")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => {controller.shareApp()},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget bottomBar(HomeController controller, initialIndex) {
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int pageIndexColor, Widget? child) {
        return CurvedNavigationBar(
            index: controller.pageIndex.value,
            backgroundColor: bgLight,
            buttonBackgroundColor: primaryColor,
            iconPadding: 9,
            // height: 75,
            items: [
              CurvedNavigationBarItem(
                  child: Icon(ElhIcons.home,
                      size: 35,
                      color: pageIndexColor == 0 ? Colors.white : fontDark),
                  label: 'Accueil',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              CurvedNavigationBarItem(
                  child: Icon(ElhIcons.handshake,
                      size: 35,
                      color: pageIndexColor == 1 ? Colors.white : fontDark),
                  label: 'Comptes',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              CurvedNavigationBarItem(
                  child: Icon(ElhIcons.doors,
                      size: 35,
                      color: pageIndexColor == 2 ? Colors.white : fontDark),
                  label: 'Épreuves',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              CurvedNavigationBarItem(
                  child: Icon(ElhIcons.pray,
                      size: 35,
                      color: pageIndexColor == 3 ? Colors.white : fontDark),
                  label: 'Prières',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              CurvedNavigationBarItem(
                  child: Icon(ElhIcons.don4,
                      size: 35,
                      color: pageIndexColor == 4 ? Colors.white : fontDark),
                  label: 'Adoration',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
              // UserProfileTopCard(controller)
            ],
            onTap: (index) {
              controller.setPageIndex(index);
              if (index == 0) {}
            });
      },
      valueListenable: controller.pageIndexColor,
    );
  }
}

class UserProfileTopCard extends StatelessWidget {
  final HomeController controller;
  UserProfileTopCard(this.controller);
  @override
  Widget build(BuildContext context) {
    // if(controller.socialProfile == null) {
    //   return Container(alignment: Alignment.center, child: userThumbDirect("", "",  29.0));
    // }
    return GestureDetector(
      onTap: () {
        //
      },
      // child: Container(
      //     alignment: Alignment.center,
      //     child: userThumbSocial(controller.socialProfile!, 29.0)),
    );
  }
}

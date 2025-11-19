import 'dart:async';

import 'package:elh/locator.dart';
import 'package:elh/models/AppNotification.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/services/NotificationService.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/views/modules/chat/ThreadsView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

import 'package:elh/main.dart' show routeObserver;
import 'package:stacked_services/stacked_services.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with RouteAware {
  List<AppNotification> _notifications = [];
  NavigationService _navigationService = locator<NavigationService>();

  late final int initialIndex;
  final DashboardController dashboardController = DashboardController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  Future<void> fetchDataUser() async {
    try {
      UserInfos? infos =
          await _userInfoReactiveService.getUserInfos(cache: true);
      String userName = infos?.fullname ?? "Utilisateur";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (infos?.email != null) {
        await prefs.setString('user_email_check', infos!.email!);
      }
      if (infos?.status != null) {
        await prefs.setString('user_status_check', infos!.status!);
      }
      print(
          "User info saved: $userName, email: ${infos?.email}, status: ${infos?.status}");
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> navigateBasedOnStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? status = prefs.getString('user_status_check') ?? "unactive";

    Timer(Duration(seconds: 1), () {
      if (status == "unactive") {
        _navigationService.navigateTo('otp-screen');
      }
    });
  }

  @override
  void initState() {
    fetchDataUser();
    navigateBasedOnStatus();
    super.initState();
    initialIndex = widget.initialIndex;
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when a covered route has been popped and this route shows again.
  @override
  void didPopNext() {
    // HomeView is visible again -> refresh
    _loadNotifications();
  }

  void _loadNotifications() async {
    final notifications = await NotificationService().fetchNotifications();

    if (!mounted) return;
    setState(() {
      _notifications = notifications;
    });
  }
  // In HomeViewState (add these methods)

  bool _isAutoAckTitle(String t) {
    return t == "Un versement a été supprimé" ||
        t == "Mise à jour d'un versement" ||
        t == "Un nouveau versement a été ajouté" ||
        t == "Versement Accepté" ||
        t == "Versement Refusé";
  }

  Future<void> _ackAutoNotifsAfterClose() async {
    try {
      // Re-fetch pour avoir l'état le plus frais après que l'utilisateur a vu la liste
      final latest = await NotificationService().fetchNotifications();

      final toAck = latest
          .where((n) => n.isRead == false && _isAutoAckTitle(n.title))
          .map((n) => n.id)
          .toList();

      if (toAck.isEmpty) {
        if (!mounted) return;
        setState(() {
          _notifications = latest; // au cas où ça a changé pendant l'ouverture
        });
        return;
      }

      // Appel backend: POST /elh-api/notifs/ack
      await NotificationService().acknowledgeMany(toAck);

      if (!mounted) return;
      setState(() {
        // Marquer comme "validée" localement + rafraîchir la source
        for (final n in latest) {
          if (toAck.contains(n.id)) {
            n.status = 'validée';
          }
        }
        _notifications = latest;
      });
    } catch (e) {
      // Optionnel: log / snackbar
      // print('Bulk ack after close failed: $e');
    }
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
                    _loadNotifications();
                  },
                  children: [
                    DashboardView(
                      controller: dashboardController,
                      goToTab: (index) => controller.setPageIndex(index),
                    ),
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

  void _showNotificationsModal(BuildContext context) async {
    // État local de la bannière d'erreur pour ce modal
    String? errorText;
    String? successText;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StatefulBuilder(
                builder: (context, setStateModal) {
                  return Column(
                    children: [
                      // handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // --- BANNIÈRE D'ERREUR (rouge) ---
                      if (errorText != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setStateModal(() {
                                  errorText = null; // fermer la bannière
                                }),
                                child: const Icon(Icons.close,
                                    color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        ),
                      // --- BANNIÈRE DE SUCCÈS (verte) ---
                      if (successText != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            border: Border.all(color: Colors.green.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  successText!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setStateModal(() {
                                  successText = null; // fermer la bannière
                                }),
                                child: const Icon(Icons.close,
                                    color: Colors.green, size: 20),
                              ),
                            ],
                          ),
                        ),
                      // Contenu principal
                      Expanded(
                        child: FutureBuilder<List<AppNotification>>(
                          future: NotificationService().fetchNotifications(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                    "Erreur lors du chargement des notifications"),
                              );
                            } else {
                              final pending = snapshot.data!
                                  .where((n) => n.isRead == false)
                                  .toList();

                              if (pending.isEmpty) {
                                return const Center(
                                  child: Text("Aucune notification en attente"),
                                );
                              }

                              return ListView.builder(
                                itemCount: pending.length,
                                itemBuilder: (context, index) {
                                  final notif = pending[index];

                                  final actions = notif.datas != null &&
                                      (notif.datas is Map &&
                                          (notif.datas as Map)
                                              .containsKey('actions'));
                                  final hideActions = !actions;

                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      title: Text(notif.title),
                                      subtitle: Text(notif.message),
                                      trailing: hideActions
                                          ? null
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.check,
                                                      color: Colors.green),
                                                  onPressed: () async {
                                                    final res =
                                                        await NotificationService()
                                                            .respondNotif(
                                                                notif.id,
                                                                'accept');

                                                    if (res == 200) {
                                                      // succès : nettoyer l'erreur affichée si besoin

                                                      setStateModal(() {
                                                        errorText = null;
                                                        notif.status = 'accept';
                                                        pending.removeAt(index);
                                                      });
                                                      setState(() {
                                                        successText =
                                                            "Versement accepté";
                                                        final target =
                                                            _notifications
                                                                .firstWhere(
                                                          (n) =>
                                                              n.id == notif.id,
                                                          orElse: () => notif,
                                                        );
                                                        target.status =
                                                            'accept';
                                                      });
                                                    } else if (res == 400) {
                                                      // Afficher le message en haut en rouge
                                                      setStateModal(() {
                                                        errorText =
                                                            "Impossible d'accepter le versement : "
                                                            "le montant est supérieur au montant restant.";
                                                      });
                                                      // Optionnel: on ne change pas le statut local
                                                    } else if (res == 404) {
                                                      setStateModal(() {
                                                        errorText =
                                                            "Ce versement a déjà été supprimé.";
                                                      });
                                                      pending.removeAt(index);
                                                    } else {
                                                      setStateModal(() {
                                                        errorText =
                                                            "Erreur lors de l'acceptation du versement. Veuillez réessayer.";
                                                      });
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    final res =
                                                        await NotificationService()
                                                            .respondNotif(
                                                                notif.id,
                                                                'decline');

                                                    if (res == 200) {
                                                      setStateModal(() {
                                                        errorText = null;
                                                        notif.status =
                                                            'decline';
                                                        pending.removeAt(index);
                                                      });
                                                      setState(() {
                                                        successText =
                                                            "Versement refusé";
                                                        final target =
                                                            _notifications
                                                                .firstWhere(
                                                          (n) =>
                                                              n.id == notif.id,
                                                          orElse: () => notif,
                                                        );
                                                        target.status =
                                                            'decline';
                                                      });
                                                    } else if (res == 404) {
                                                      setStateModal(() {
                                                        errorText =
                                                            "Ce versement a déjà été supprimé.";
                                                      });
                                                      pending.removeAt(index);
                                                    } else {
                                                      setStateModal(() {
                                                        errorText =
                                                            "Erreur lors de l'acceptation du versement. Veuillez réessayer.";
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
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    // Après fermeture du modal : ACK auto des notifs info
    await _ackAutoNotifsAfterClose();
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
                                '${firstName}',
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
                        .any((n) => n.isRead == false), // check dynamically
                    badgeContent: Text(
                      '${_notifications.where((n) => n.isRead == false).length}',
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

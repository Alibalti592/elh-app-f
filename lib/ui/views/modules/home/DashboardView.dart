import 'package:elh/common/elh_icons.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/salat.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Salat/SalatCard.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/views/modules/home/DashboardController.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:elh/ui/views/modules/home/PageNavigationView.dart';
import 'package:get/get.dart' hide Transition;

class DashboardView extends StatefulWidget {
  final DashboardController controller;
  final ValueChanged<int>? goToTab;
  const DashboardView({
    Key? key,
    required this.controller,
    this.goToTab, // ✅ accept it
  }) : super(key: key);
  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<DashboardController>.reactive(
      viewModelBuilder: () => widget.controller,
      builder: (context, controller, child) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // Top info/prayer ard (under the AppBar)
              if (!controller.notifIsOn) const SizedBox(height: 8),
              if (!controller.notifIsOn)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    'Attention certaines fonctionnalités nécessitent l’activation des notifications',
                    style: smallText,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (controller.notifIsOn) UIHelper.verticalSpace(15),

              // Main scrollable content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshDatas,
                  child: ListView(
                    children: [
                      _topInfoCard(controller),
                      const SizedBox(height: 10),

                      // Mes comptes
                      _buildSectionHeader("Mes Comptes", () {}),
                      const SizedBox(height: 10),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 12.0;

                          // Make width strictly less than maxWidth to avoid wrap line-breaks
                          final cardWidth =
                              (((constraints.maxWidth - spacing) / 2)
                                  .floorToDouble());

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _buildCard(
                                  'Je dois',
                                  "Note et suis l'argent que tu dois",
                                  Image.asset(
                                    'assets/images/Group-7.png',
                                    width: 40,
                                    height: 40,
                                    color:
                                        const Color.fromRGBO(220, 198, 169, 1),
                                  ),
                                  0,
                                  controller,
                                  'onm',
                                  actionColor:
                                      const Color.fromRGBO(220, 198, 169, 1),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildCard(
                                  'On me doit',
                                  "Note et suis l'argent qu'on te dois ",
                                  Image.asset(
                                    'assets/images/Group-7.png',
                                    width: 34,
                                    height: 34,
                                    color:
                                        const Color.fromRGBO(143, 151, 121, 1),
                                  ),
                                  0,
                                  controller,
                                  'jed',
                                  actionColor:
                                      const Color.fromRGBO(143, 151, 121, 1),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        width: 349,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              controller.goTo('testament');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row: Icon + Title + Subtitle
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              31, 41, 55, 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/document-text.png',
                                            width: 18,
                                            height: 18,
                                            color: const Color.fromRGBO(
                                                55, 65, 81, 1),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Title + Subtitle column
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mon Testament',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Note et actualise le',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(
                                                    75, 85, 99, 1)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Bottom Action
                                  Text(
                                    'Gère →',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromRGBO(55, 65, 81, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mes épreuves
                      _buildSectionHeader(
                        "Épreuves",
                        () {},
                      ),

                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 12.0;

                          // Make sure 2 * cardWidth + spacing < maxWidth on all DPRs
                          final cardWidth =
                              ((constraints.maxWidth - spacing) / 2)
                                  .floorToDouble();

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _buildCard(
                                  'AL-JANAZA',
                                  "Être informé par des Salât Al-Janaza partagées par votre communauté.",
                                  Image.asset(
                                    'assets/images/pray.png',
                                    width: 18,
                                    height: 18,
                                    color:
                                        const Color.fromRGBO(220, 198, 169, 1),
                                  ),
                                  0,
                                  controller,
                                  'salat',
                                  actionColor:
                                      const Color.fromRGBO(220, 198, 169, 1),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildCard(
                                  'Cartes Virtuelles de circonstance',
                                  'Gère tes cartes virtuelles de circonstance.',
                                  Image.asset(
                                    'assets/images/card-multiple.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                  0,
                                  controller,
                                  'cartes',
                                  actionColor:
                                      const Color.fromRGBO(143, 151, 121, 1),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      // Découvrez Muslim Connect
                      Text(
                        'Découvres Muslim Connect',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDiscoverCard(
                        'Guide Spirituel',
                        'Accède à la Qibla, aux horaires de prière, aux mosquées à proximité et apprends les prières essentielles.',
                        Image.asset(
                          color: primaryColor,
                          'assets/images/pray.png', // replace with your logo
                          width: 18,
                          height: 18,
                        ),
                        onTap: () => widget.goToTab?.call(3),
                      ),
                      const SizedBox(height: 10),
                      _buildDiscoverCard(
                        'Œuvres Charitables',
                        'Parraine un orphelin, construit un puits, offre un Coran, contribue à la construction d’une mosquée ...',
                        Image.asset(
                          color: primaryColor,
                          'assets/images/pray.png', // replace with your logo
                          width: 18,
                          height: 18,
                        ),
                        onTap: () => widget.goToTab?.call(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========= TOP INFO / PRAYER CARD =========
  Widget _topInfoCard(DashboardController controller) {
    if (controller.isLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: UIHelper.lineLoaders(3, 15),
        ),
      );
    }

    if (controller.needDefineLocation) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 4),
              const Text(
                'Pour visualiser les heures de prière merci de préciser votre localisation',
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(10),
              ElevatedButton(
                onPressed: controller.setLocation,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Color(0xFFBE914F),
                ),
                child: Icon(MdiIcons.homeSearch, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Normal state
    final city = controller.praytime?.location.city ?? '';
    final date = controller.praytime?.date ?? '';
    final dateMuslim = controller.praytime?.dateMuslim ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Left side: City + Next Prayer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City and date
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Group-5.png',
                        width: 38,
                        height: 38,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.isEmpty ? '—' : city,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$date - $dateMuslim',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Next Prayer
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/Group-6.png',
                            width: 38,
                            height: 38,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prochaine Prière',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                __nextPrayTime(controller),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ⬆️ Add top margin before the buttons row
                  const SizedBox(height: 14),

                  // ➡️ Buttons row: spaced between, larger icons, primaryColor
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Item 1: Voir Qibla
                      InkWell(
                        onTap: () => controller.goTo('qibla'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.explore,
                                  size: 26, color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Qibla',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Item 2: Voir toutes les prières
                      InkWell(
                        onTap: () =>
                            controller.goTo('pray'), // change route if needed
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 26, color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Toutes les prières',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ========= SECTION HEADER =========
  Widget _buildSectionHeader(String title, VoidCallback onTap, {int? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Section title
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Right side: counter + "Voir Tout"
        Row(
          children: [
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    String subtitle,
    Widget? iconWidget,
    int badgeCount,
    DashboardController controller,
    String viewName, {
    Color actionColor = primaryColor,
    double defaultHeight = 170,
    double expandedHeight = 200,
  }) {
    final Widget iconChild = iconWidget ?? const SizedBox.shrink();

    // Vérifie si le sous-titre est trop long
    bool isLongSubtitle = subtitle.length > 25;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (viewName.isNotEmpty) {
            controller.goTo(viewName); // navigation
          }
        },
        child: SizedBox(
          height: isLongSubtitle ? expandedHeight : defaultHeight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Badge + Icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badgeCount > 0)
                      Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (badgeCount > 0) const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: iconChild),
                    ),
                  ],
                ),
                // Middle: Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: isLongSubtitle ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fontGreyDark,
                      ),
                    ),
                  ],
                ),
                // Bottom: Action
                Text(
                  'Gère →',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========= DISCOVER (full-width) =========
  Widget _buildDiscoverCard(
    String title,
    String subtitle,
    Widget iconWidget, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15.0), // ✅ paramètre nommé
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: iconWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(color: fontGreyDark, fontSize: 13),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========= YOUR EXISTING HELPERS (kept, with minor safe tweaks if any) =========

  _dettesBlock(controller) {
    List widgets = [];
    widgets.add(__detteBlocktype(controller, 'onm'));
    widgets.add(__detteBlocktype(controller, 'jed'));
    return widgets;
  }

  __deuilCard(controller) {
    List widgets = [];
    if (controller.nbDeuils.toInt() > 0) {
      widgets.add(GestureDetector(
        onTap: () {
          controller.goToDeuil();
        },
        child: Card(
          color: primaryColor,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              controller.nbDeuils != null
                  ? Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            color: const Color(0xFFf6f6f6),
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Text(controller.nbDeuils.toString(),
                                style: TextStyle(
                                    color: fontDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                      ))
                  : Container(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(Icons.event_repeat_outlined,
                        size: 33, color: Colors.white),
                    SizedBox(height: 5),
                    Text('Période de deuil',
                        textScaler: TextScaler.linear(1.0),
                        style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 15.0),
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: Icon(Icons.arrow_circle_right_outlined,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ));
    }
    return widgets;
  }

  __detteBlocktype(DashboardController controller, type) {
    String title = 'Prêts arrivés à échéance';
    var valueIdentifier = controller.dashboardStore.nbOnms;
    IconData iconCenter = ElhIcons.don;
    if (type == 'jed') {
      title = 'Emprunts arrivés à échéance';
      valueIdentifier = controller.dashboardStore.nbJeds;
    } else if (type == 'carte') {
      title = 'Cartes virtuelles reçues';
      iconCenter = Icons.app_registration_outlined;
      valueIdentifier = controller.dashboardStore.nbAmanas;
    }

    return GestureDetector(
      onTap: () {
        if (type == 'carte') {
          controller.goToCartes();
        } else {
          controller.goToDettes(type);
        }
      },
      child: Card(
        color: primaryColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    color: const Color(0xFFf6f6f6),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: Text(
                    valueIdentifier.value.toString(),
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                        color: fontDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(iconCenter, size: 33, color: Colors.white),
                  UIHelper.verticalSpace(5),
                  Text(
                    title,
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child:
                  Icon(Icons.arrow_circle_right_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salat(DashboardController controller, Salat salat) {
    return Hero(
      tag: "salat-tag-${salat.id}",
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (context) => Center(child: SalatCard(salat: salat)),
              ),
            );
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          tileColor: Colors.white,
          title: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${salat.firstname} ${salat.lastname}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: fontDark,
                          fontFamily: 'Karla')),
                  UIHelper.verticalSpace(5),
                  salat.mosque != null
                      ? Text("Mosquée : ${salat.mosque?.name ?? ''}",
                          style: TextStyle(color: fontGreyDark, fontSize: 12))
                      : Container(),
                  UIHelper.verticalSpace(2),
                  Text("Le ${salat.dateDisplay}",
                      style: TextStyle(color: fontGreyDark, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  __currentDettes(DashboardController controller) {
    if (controller.isLoadingDettes) {
      return Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: UIHelper.lineLoaders(4, 3),
      );
    }

    TextStyle stylelibele = const TextStyle(
      fontFamily: 'Karla',
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 14.0,
    );

    List<Widget> obligationWigets = [];
    if (controller.obligations.isEmpty) {
      return Container();
    } else {
      obligationWigets.add(Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: const Text(
          "Dettes arrivées à échéance",
          textScaler: TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Karla',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 15.0,
          ),
          textAlign: TextAlign.start,
        ),
      ));

      if (controller.jeds.isNotEmpty) {
        obligationWigets.add(Text("Je dois", style: stylelibele));
        for (var obligation in controller.jeds) {
          obligationWigets.add(__obligation(controller, obligation));
        }
      }
      if (controller.onms.isNotEmpty) {
        obligationWigets.add(Text("On me dois", style: stylelibele));
        for (var obligation in controller.onms) {
          obligationWigets.add(__obligation(controller, obligation));
        }
      }
      if (controller.amanas.isNotEmpty) {
        obligationWigets.add(Text("Amanas", style: stylelibele));
        for (var obligation in controller.amanas) {
          obligationWigets.add(__obligation(controller, obligation));
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: obligationWigets),
    );
  }

  Widget __obligation(DashboardController controller, Obligation obligation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Hero(
        tag: "obligation-tag-${obligation.id}",
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            onTap: () => controller.goToDette(obligation),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            tileColor: Colors.white,
            title: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${obligation.firstname} ${obligation.lastname}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Karla')),
                    UIHelper.verticalSpace(2),
                    Text("Montant :  ${obligation.amount}",
                        style: TextStyle(color: fontGreyDark, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Re-used countdown builder (shown inside top card)
  Widget __nextPrayTime(controller) {
    return ValueListenableBuilder<String>(
      valueListenable: controller.nextPrayHour,
      builder: (context, nextPrayHour, child) {
        if (nextPrayHour.isEmpty) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${controller.nextPrayName} dans $nextPrayHour",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

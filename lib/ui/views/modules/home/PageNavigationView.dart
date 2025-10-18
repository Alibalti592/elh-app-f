import 'package:cached_network_image/cached_network_image.dart';
import 'package:elh/common/elh_icons.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/home/PageNavigationController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:elh/common/elh_icons.dart';

class PageNavigationView extends StatefulWidget {
  final String pageKey;
  PageNavigationView(this.pageKey);
  @override
  PageNavigationViewState createState() =>
      PageNavigationViewState(this.pageKey);
}

class PageNavigationViewState extends State<PageNavigationView>
    with AutomaticKeepAliveClientMixin {
  final String pageKey;
  @override
  bool get wantKeepAlive =>
      true; //AutomaticKeepAliveClientMixin eviter rebuild au changement page
  PageNavigationViewState(this.pageKey);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PageNavigationController>.reactive(
      viewModelBuilder: () => PageNavigationController(this.pageKey),
      builder: (context, controller, child) => Container(
        color: Colors.white,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  // VIDEO
                  if (controller.youtubecontroller != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: YoutubePlayer(
                          controller: controller.youtubecontroller!,
                          liveUIColor: Colors.amber,
                          bottomActions: [
                            const SizedBox(width: 14.0),
                            CurrentPosition(),
                            const SizedBox(width: 8.0),
                            ProgressBar(isExpanded: true),
                            RemainingDuration(),
                            const PlaybackSpeedButton(),
                          ],
                        ),
                      ),
                    ),

                  // IMAGE
                  if (controller.image != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: controller.image!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),

                  // TEXTE HTML
                  if (controller.content != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HtmlWidget(
                        controller.content!,
                        onTapUrl: (url) => controller.openUrl(url),
                        textStyle: TextStyle(fontSize: 14, color: fontGreyDark),
                      ),
                    ),

                  if (pageKey == 'pray')
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;

                        // Ensure 2 * cardWidth + spacing < maxWidth to avoid Wrap line breaks
                        final cardWidth = ((constraints.maxWidth - spacing) / 2)
                            .floorToDouble();

                        return Wrap(
                          spacing: spacing, // horizontal spacing
                          runSpacing: spacing, // vertical spacing
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Qiblah',
                                Icon(
                                  Icons.explore_outlined,
                                  size: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'qibla',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Horaires de prière',
                                Icon(
                                  ElhIcons.pray,
                                  size: 18,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'pray',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Mosquées',
                                Icon(
                                  Icons.mosque_outlined,
                                  size: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'mosque',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Apprendre la prière',
                                SvgPicture.asset(
                                  'assets/icon/muslim-read.svg',
                                  width: 18,
                                  height: 18,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'learn_pray',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Apprendre la Salât Al-Janaza',
                                SvgPicture.asset(
                                  'assets/icon/man-hands.svg',
                                  width: 18,
                                  height: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'learn_salat',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Sourate facile à apprendre',
                                Image.asset(
                                  'assets/images/clock.png',
                                  width: 18,
                                  height: 18,
                                ),
                                0,
                                controller,
                                'learn_sourat',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  if (pageKey == 'don')
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        const cardOuterHMargin =
                            0.0; // set if your _buildCard adds external horizontal margin

                        // Ensure 2 * cardWidth + spacing (+ margins) < maxWidth across all DPRs
                        final cardWidth = ((constraints.maxWidth -
                                    spacing -
                                    2 * cardOuterHMargin) /
                                2)
                            .floorToDouble();

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Parrainer un orphelin',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'parrain',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Construire un puits ',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'puit',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Offrir un Coran',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'offerCoran',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Participer à la construction d’une mosquée ',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'buildMosque',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Omra / Hajj par procuration',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'hajiProcur',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Espace d’entraide',
                                Icon(
                                  ElhIcons.don3,
                                  size: 18,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'entraide',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  if (pageKey == 'dette')
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;

                        // If _buildCard adds external horizontal margin (e.g., Container(margin: EdgeInsets.symmetric(horizontal: 8))),
                        // set this to that value (e.g., 😎. Otherwise leave 0.
                        const cardOuterHMargin = 0.0;

                        // Ensure 2 * cardWidth + spacing + external margins < maxWidth on all DPRs
                        final cardWidth = ((constraints.maxWidth -
                                    spacing -
                                    2 * cardOuterHMargin) /
                                2)
                            .floorToDouble();

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Je dois',
                                Image.asset(
                                  'assets/images/Group-7.png',
                                  width: 40,
                                  height: 40,
                                  color: const Color.fromRGBO(220, 198, 169, 1),
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
                                Image.asset(
                                  'assets/images/Group-7.png',
                                  width: 34,
                                  height: 34,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'jed',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Mes Amanas',
                                Image.asset(
                                  'assets/images/Group-7.png',
                                  width: 34,
                                  height: 34,
                                ),
                                0,
                                controller,
                                'amana',
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Mon Testament',
                                Image.asset(
                                  'assets/images/document-text.png',
                                  width: 34,
                                  height: 34,
                                  color: const Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'testament',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Testaments partagés avec moi',
                                Image.asset(
                                  'assets/images/document-attach.png',
                                  width: 18,
                                  height: 18,
                                ),
                                0,
                                controller,
                                'sharedTestamentWithMe',
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Mes jours de jeûne à rattraper',
                                Image.asset(
                                  'assets/images/clock.png',
                                  width: 18,
                                  height: 18,
                                ),
                                0,
                                controller,
                                'jeunRamadan',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  if (pageKey == 'deuil')
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        // Ensure 2 * cardWidth + spacing < maxWidth across all DPRs
                        final cardWidth = ((constraints.maxWidth - spacing) / 2)
                            .floorToDouble();

                        return Wrap(
                          spacing: spacing, // horizontal spacing
                          runSpacing: spacing, // vertical spacing
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Créer des cartes virtuelles de circonstance',
                                const Icon(
                                  Icons.app_registration_outlined,
                                  size: 18,
                                  color: Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'cartes',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Publications des Salât Al-Janaza',
                                const Image(
                                  image:
                                      AssetImage("assets/icon/salat-icon.png"),
                                  color: Color.fromRGBO(143, 151, 121, 1),
                                  height: 18,
                                  width: 18,
                                ),
                                0,
                                controller,
                                'salat',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Formalités administratives',
                                const Icon(
                                  Icons.text_snippet_outlined,
                                  size: 18,
                                  color: Color.fromRGBO(220, 198, 169, 1),
                                ),
                                0,
                                controller,
                                'todo',
                                actionColor:
                                    const Color.fromRGBO(220, 198, 169, 1),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Calcul de la période de deuil',
                                const Icon(
                                  Icons.event_repeat_outlined,
                                  size: 18,
                                  color: Color.fromRGBO(143, 151, 121, 1),
                                ),
                                0,
                                controller,
                                'periode',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 1, 1),
                              ),
                            ),
                            SizedBox(
                                width: cardWidth,
                                child: _buildCard(
                                    'Bid’ah / Sunnah',
                                    Icon(MdiIcons.checkDecagramOutline,
                                        size: 18,
                                        color:
                                            Color.fromRGBO(220, 198, 169, 1)),
                                    0,
                                    controller,
                                    'bidha',
                                    actionColor:
                                        Color.fromRGBO(220, 198, 169, 1))),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                'Invocations Doua',
                                const Image(
                                  image:
                                      AssetImage("assets/icon/pray-hands.png"),
                                  height: 18,
                                  width: 18,
                                ),
                                0,
                                controller,
                                'duha',
                                actionColor:
                                    const Color.fromRGBO(143, 151, 121, 1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  // G,RID DES CARTES

                  UIHelper.verticalSpace(60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _navCards(PageNavigationController controller, pageKey) {
    List<Widget> cards = [];
    if (pageKey == 'pray') {
      cards.add(__navCard(Icon(Icons.explore_outlined, size: 33), 'Qiblah',
          controller, 'qibla'));
      cards.add(__navCard(Icon(ElhIcons.pray, size: 33), 'Horaires des prières',
          controller, 'pray'));
      cards.add(__navCard(Icon(Icons.mosque_outlined, size: 33), 'Mosquées',
          controller, 'mosque'));
      cards.add(__navCard(
          SvgPicture.asset(
            'assets/icon/muslim-read.svg',
            color: Colors.black,
            height: 38,
            width: 25.0,
            // fit: BoxFit.fill,
          ),
          'Apprendre la prière',
          controller,
          'learn_pray'));
      cards.add(__navCard(
          SvgPicture.asset(
            'assets/icon/man-hands.svg',
            color: Colors.black,
            height: 40,
            width: 35.0,
            // fit: BoxFit.fill,
          ),
          'Apprendre Salât Al-Janaza',
          controller,
          'learn_salat',
          fontSize: 14.0));
      cards.add(__navCard(
          SvgPicture.asset(
            'assets/icon/Icon_Quran.svg',
            color: Colors.black,
            height: 45,
            width: 35.0,
          ),
          'Sourates faciles à apprendre',
          controller,
          'learn_sourat',
          fontSize: 13.0));
    } else if (pageKey == 'dette') {
      cards.add(_buildCard(
        "Mes prêts",
        Icon(ElhIcons.don, size: 40, color: Colors.black),
        0,
        controller, // pass the controller
        'prets',
      ));
      cards.add(_buildCard(
        "Mes dettes",
        Icon(ElhIcons.emprun, size: 40, color: Colors.black),
        2,
        controller, // pass the controller
        'mes_prets', // exemple badge
      ));
      cards.add(_buildCard(
        "Mes Amanas",
        Icon(ElhIcons.amana, size: 40, color: Colors.black),
        0,
        controller, // pass the controller
        'mes_prets',
      ));
      cards.add(_buildCard(
        "Mon Testament",
        Icon(ElhIcons.feather, size: 40, color: Colors.black),
        0,
        controller, // pass the controller
        'mes_prets',
      ));
      cards.add(_buildCard(
        "Testaments partagés avec moi",
        SvgPicture.asset("assets/icon/plumes.svg", height: 38, width: 25),
        1,
        controller, // pass the controller
        'mes_prets',
      ));
      cards.add(_buildCard(
        "Jours de jeûn à rattraper",
        SvgPicture.asset("assets/icon/man-hands.svg", height: 38, width: 25),
        0,
        controller, // pass the controller
        'mes_prets',
      ));
    } else if (pageKey == 'don') {
      // cards.add(__navCard(Icon(ElhIcons.don3, size: 33), 'Ramadan', controller, 'ramadan'));
      cards.add(__navCard(Icon(ElhIcons.don3, size: 33),
          'Parrainer un orphelin', controller, 'parrain'));
      cards.add(__navCard(Icon(ElhIcons.don3, size: 33), 'Construire un puits ',
          controller, 'puit'));
      cards.add(__navCard(Icon(ElhIcons.don3, size: 33), 'Offrir un Coran',
          controller, 'offerCoran'));
      cards.add(__navCard(Icon(ElhIcons.don3, size: 33),
          'Construire une mosquée ', controller, 'buildMosque'));
      cards.add(__navCard(Icon(ElhIcons.don3, size: 33),
          'Omra/ hajj par procuration ', controller, 'hajiProcur'));
      // cards.add(  __navCard(Icon(ElhIcons.don3, size: 33), 'Espace entraide', controller, 'entraide'));
    } else if (pageKey == 'deuil') {
      // cards.add(__navCard(Icon(Icons.connect_without_contact, size: 33), 'Contacter des pompes funèbres', controller, 'dece',
      //     iconWrapHeight: 50.0, fontSize: 13.0));
      cards.add(__navCard(Icon(Icons.app_registration_outlined, size: 33),
          'Créer des cartes virtuelles de circonstance', controller, 'cartes',
          iconWrapHeight: 45.0, fontSize: 13.0));
      cards.add(__navCard(
          Image(
              image: AssetImage("assets/icon/salat-icon.png"),
              height: 40.0,
              width: 50),
          'Publications des Salât Al-Janaza',
          controller,
          'salat',
          fontSize: 13.0));
      // cards.add(__navCard(Icon(Icons.home_work_outlined, size: 33), 'Pompe funèbre', controller, 'pompe'));
      cards.add(__navCard(Icon(Icons.text_snippet_outlined, size: 33),
          'Formalités administratives', controller, 'todo',
          fontSize: 13.0));
      cards.add(__navCard(
          Icon(Icons.event_repeat_outlined, size: 33),
          'Calcul de la période de deuil',
          fontSize: 13.0,
          controller,
          'periode'));
      cards.add(__navCard(Icon(MdiIcons.checkDecagramOutline, size: 33),
          'Bid’ah / Sunnah', controller, 'bidha'));
      cards.add(__navCard(
          Image(
              image: AssetImage("assets/icon/pray-hands.png"),
              height: 45.0,
              width: 60),
          'Invocations Doua',
          controller,
          'duha',
          iconWrapHeight: 45.0));
      // cards.add(__navCard(Icon(Icons.balance_outlined, size: 33), 'Héritage', controller, 'herite', iconWrapHeight: 45.0));
    }
    return cards;
  }

  Widget _buildCard(
    String title,
    Widget? iconWidget,
    int badgeCount,
    PageNavigationController controller,
    dynamic viewName, {
    Color actionColor = primaryColor,
    double cardHeight = 170, // fixed height
  }) {
    final Widget iconChild = iconWidget ?? const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (controller != null && viewName != null) {
            controller.gotToView(viewName);
          }
        },
        child: SizedBox(
          height: cardHeight, // enforce same height
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
                                fontWeight: FontWeight.w700),
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

                // Middle: Title only
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),

                // Bottom: Action
                Text(
                  'Gérez →',
                  style: TextStyle(
                    fontSize: 13,
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

  __navCard(icon, label, PageNavigationController controller, viewName,
      {iconWrapHeight = 50.0, fontSize = 15.0}) {
    const bgWhithe = const Color(0xffffffff);
    return Center(
      child: SizedBox(
        width: 140, // max width
        height: 140, // max height
        child: GestureDetector(
          onTap: () {
            controller.gotToView(viewName);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: bgWhithe,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                controller.showAddIcon(viewName)
                    ? Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xFFf6f6f6),
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(Icons.add, color: fontDark, size: 20)))
                    : Container(),
                Column(
                  mainAxisSize: MainAxisSize.min, // shrink to content
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 55,
                      height: iconWrapHeight,
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: icon),
                    ),
                    UIHelper.verticalSpace(10),
                    Text(
                      label,
                      textScaler: TextScaler.linear(1.0),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: fontSize,
                          color: Colors.black,
                          fontFamily: 'Karla'),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

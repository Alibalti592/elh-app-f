import 'package:cached_network_image/cached_network_image.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Page/PageContentController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PageContentView extends StatefulWidget {
  final String pageKey;
  final String pageTitle;
  final String? textWhatsapp;
  PageContentView(this.pageKey, this.pageTitle, {this.textWhatsapp});
  @override
  PageContentViewState createState() =>
      PageContentViewState(this.pageKey, this.pageTitle,
          textWhatsapp: this.textWhatsapp);
}

class PageContentViewState extends State<PageContentView>
    with AutomaticKeepAliveClientMixin {
  final String pageKey;
  final String pageTitle;
  final String? textWhatsapp;
  @override
  bool get wantKeepAlive =>
      true; //AutomaticKeepAliveClientMixin eviter rebuild au changement page
  PageContentViewState(this.pageKey, this.pageTitle, {this.textWhatsapp});
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PageContentController>.reactive(
        viewModelBuilder: () => PageContentController(this.pageKey),
        builder: (context, controller, child) => SafeArea(
            child: Scaffold(
                backgroundColor: bgLightV2,
                appBar: AppBar(
                  elevation: 0,
                  iconTheme: new IconThemeData(color: Colors.white),
                  backgroundColor: Colors
                      .transparent, // 🔑 transparent pour voir le gradient
                  title: Text(this.pageTitle, style: headerTextWhite),
                  actions: [],
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(220, 198, 169, 1.0), // light beige
                          Color.fromRGBO(143, 151, 121, 1.0), // olive green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                floatingActionButton: controller.showContactezNous()
                    ? FloatingActionButton.extended(
                        onPressed: () {
                          controller.openWhatsap(this.textWhatsapp);
                        },
                        backgroundColor: primaryColor,
                        label: const Text(
                          'Contacte-nous !',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'Karla'),
                        ),
                      )
                    : null,
                extendBody: true,
                body: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  children: [
                    controller.isLoading ? BBloader() : Container(),
                    controller.youtubecontroller != null
                        ? Container(
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
                                  ]),
                            ),
                          )
                        : Container(),
                    controller.image != null
                        ? Container(
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
                          )
                        : Container(),
                    controller.content != null
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: HtmlWidget(controller.content!,
                                onTapUrl: (url) => controller.openUrl(url),
                                textStyle: TextStyle(
                                    fontSize: 14, color: fontGreyDark)),
                          )
                        : Container(),
                    UIHelper.verticalSpace(30),
                  ],
                ))));
  }
}

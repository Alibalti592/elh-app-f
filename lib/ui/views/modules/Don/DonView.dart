import 'package:cached_network_image/cached_network_image.dart';
import 'package:elh/models/don.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Don/DonController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:stacked/stacked.dart';

class DonView extends StatefulWidget {
  @override
  DonViewState createState() => DonViewState();
}

class DonViewState extends State<DonView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DonController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              title: Text('Parrainer un orphelin', style: headerTextWhite),
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
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
              actions: [],
            ),
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: RefreshIndicator(
                      child: ListView(
                        children: dons(controller),
                      ),
                      onRefresh: controller.refreshData,
                    ),
                  )),
        viewModelBuilder: () => DonController());
  }

  List<Widget> dons(DonController donController) {
    List<Widget> donList = [];
    donList.add(Container(
      padding: const EdgeInsets.only(left: 25, right: 20, bottom: 20, top: 15),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: HtmlWidget(
        donController.textIntro,
        onTapUrl: (url) => donController.openUrl(url),
        textStyle: TextStyle(
          fontSize: 14,
          color: fontDark,
        ),
      ),
    ));

    donController.dons.forEach((Don don) {
      donList.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            tileColor: Colors.white,
            leading: Container(
                height: double.infinity,
                width: 40,
                child: Center(
                  child: don.logo != null
                      ? CachedNetworkImage(
                          imageUrl: don.logo!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )
                      : Container(),
                )),
            title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  don.name,
                  style: headerText,
                )),
            subtitle: Column(
              children: [
                HtmlWidget(don.description,
                    onTapUrl: (url) => donController.openUrl(url),
                    textStyle: TextStyle(fontSize: 14, color: fontGrey)),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      donController.gotToLink(don);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 5),
                      child: Text('Visiter', style: linkStyle),
                    ),
                  ),
                )
              ],
            ),
          )));
    });
    donList.add(UIHelper.verticalSpace(15));
    donList.add(GestureDetector(
      onTap: () {
        donController.contact();
      },
      child: Center(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(20)),
        child: Text(
          'Contactez nous',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Karla',
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
      )),
    ));
    return donList;
  }
}

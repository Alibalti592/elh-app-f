import 'package:elh/models/Faq.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Faq/FaqController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:stacked/stacked.dart';

class FaqView extends StatefulWidget {
  @override
  FaqViewState createState() => FaqViewState();
}

class FaqViewState extends State<FaqView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FaqController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: Text('FAQ',
                  style: TextStyle(
                    fontFamily: 'inter',
                    color: white,
                  )),
              backgroundColor: Colors.transparent,
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
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      children: faqs(controller),
                    ),
                  )),
        viewModelBuilder: () => FaqController());
  }

  List<Widget> faqs(FaqController faqController) {
    List<Widget> faqList = [];
    faqController.faqs.forEach((Faq faq) {
      faqList.add(ExpansionTile(
        tilePadding: faq.isExpanded
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 15)
            : EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        collapsedShape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
        shape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
        onExpansionChanged: (bool active) =>
            faqController.setActiveFaq(faq, active),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        // trailing: Icon(Icons.keyboard_arrow_down_sharp),
        iconColor: Colors.grey,
        title: Text(faq.question,
            style: TextStyle(
                fontSize: 16.0,
                color: fontDark,
                fontWeight: FontWeight.w700,
                height: 1.4)),
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: HtmlWidget(faq.reponse,
                onTapUrl: (url) => faqController.openUrl(url)),
          ),
          UIHelper.verticalSpace(15)
        ],
      ));
      faqList.add(UIHelper.verticalSpace(10));
    });
    return faqList;
  }
}

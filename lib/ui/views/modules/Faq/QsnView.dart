import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/views/modules/Faq/QsnController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:stacked/stacked.dart';

class QsnView extends StatefulWidget {
  @override
  QsnViewState createState() => QsnViewState();
}

class QsnViewState extends State<QsnView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QsnController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Qui sommes nous ?", style: headerTextWhite),
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
            extendBody: true,
            body: SafeArea(
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: ListView(
                children: [
                  controller.isLoading
                      ? BBloader()
                      : HtmlWidget(controller.content),
                ],
              ),
            ))),
        viewModelBuilder: () => QsnController());
  }
}

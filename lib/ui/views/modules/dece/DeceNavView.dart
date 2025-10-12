import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/views/modules/dece/DeceListView.dart';
import 'package:elh/ui/views/modules/dece/DeceNavController.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DeceNavView extends StatefulWidget {
  @override
  DeceNavViewState createState() => DeceNavViewState();
}

class DeceNavViewState extends State<DeceNavView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeceNavController>.reactive(
        viewModelBuilder: () => DeceNavController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.black),
              backgroundColor: Colors.transparent,
              title: Text("Décès", style: headerText),
              actions: [],
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
            ),
            extendBody: true,
            body: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.navigateTo(DeceListView());
                  },
                  child: Text('Décès décalarès'),
                )
              ],
            )));
  }
}

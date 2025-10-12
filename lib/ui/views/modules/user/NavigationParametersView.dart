import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/userInfos.dart';
import 'package:intl/intl.dart';

class NavigationParametersView extends StatefulWidget {
  final UserInfos userInfos;
  const NavigationParametersView({ Key? key, required this.userInfos}) : super(key: key);
  @override
  NavigationParametersViewState createState() => NavigationParametersViewState(userInfos);
}

class NavigationParametersViewState extends State<NavigationParametersView>  {
  final UserInfos userInfos;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  NavigationParametersViewState(this.userInfos) {
    //
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          elevation: 2,
          title: const Text('Mes paramètres'),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.account_circle_outlined),
                trailing: Icon(Icons.chevron_right),
                title: Text('Mes coordonnées'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('profileInfos', arguments : {
                    "userInfos": userInfos
                  });
                },
              )
            ],
          ),
        ));
  }
}
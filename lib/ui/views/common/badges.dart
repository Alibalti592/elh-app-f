import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<Widget> badgeList(baseUrl, badgesNames) {
  List<Widget> listBadges = [];
  badgesNames.forEach((badgeName) {
    listBadges.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Image.network("$baseUrl$badgeName")
    ));
  });
  return listBadges;
}
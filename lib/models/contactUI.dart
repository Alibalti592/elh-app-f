//V2 !
import 'dart:convert';

import 'package:elh/models/userUI.dart';

List<ContactUI> contactsFromJson(String str) => List<ContactUI>.from(json.decode(str).map((x) => ContactUI.fromJson(x)));

String contactsToJson(List<ContactUI> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContactUI {
  ContactUI({
    required this.type,
    required this.userUi,
    required this.canContact,
    required this.hasMessage,
  });

  String type;
  UserUi userUi;
  bool canContact;
  bool hasMessage;

  factory ContactUI.fromJson(Map<String, dynamic> json) => ContactUI(
    type: json["type"],
    userUi: UserUi.fromJson(json["userUI"]),
    canContact: json["canContact"],
    hasMessage: json["hasMessage"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "userUI": userUi.toJson(),
    "canContact": canContact,
    "hasMessage": hasMessage,
  };
}

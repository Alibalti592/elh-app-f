import 'dart:convert';

import 'package:elh/models/salat.dart';
import 'package:intl/intl.dart';

List<Carte> carteFromJson(jsondata) => List<Carte>.from(jsondata.map((x) => Carte.fromJson(x)));
String carteToJson(List<Carte> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Carte {
  int? id;
  String type;
  String typeLabel;
  String title;
  String onmyname;
  String phone;
  String phonePrefix;
  String afiliation;
  String afiliationLabel;
  String firstname;
  String lastname;
  String content;
  String sex;
  String locationName = "";
  String? dateDisplay;
  Salat? salat;
  DateTime? date;
  bool canEdit;

  Carte({
    this.id,
    required this.afiliation,
    this.title = "",
    this.onmyname = "myname",
    this.type = 'death',
    this.typeLabel = 'Annoncer un décès',
    this.phone = '',
    this.phonePrefix = '+33',
    required this.afiliationLabel,
    required this.firstname,
    required this.lastname,
    required this.content,
    this.locationName = "",
    this.sex = 'm',
    this.date,
    required this.dateDisplay,
    required this.canEdit,
    this.salat,
  });

  factory Carte.fromJson(Map<String, dynamic> json) => Carte(
    id: json["id"],
    type: json["type"], //death || malade
    title: json["title"],
    typeLabel: json["typeLabel"], //death || malade
    onmyname: json["onmyname"], //myname || toother
    afiliation: json["afiliation"],
    afiliationLabel: json["afiliationLabel"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    locationName: json["locationName"],
    phone: json["phone"],
    phonePrefix: json["phonePrefix"],
    sex: json["sex"],
    dateDisplay:  json["date"] != null ? DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(DateTime.parse(json["date"])) : "",
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    content: json["content"],
    canEdit: json["canEdit"],
    salat: json["salat"] != null ? Salat.fromJson(json["salat"]) : null
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "afiliation": afiliation,
    "onmyname": onmyname,
    "phone": phone,
    "phonePrefix": phonePrefix,
    "firstname": firstname,
    "locationName": locationName,
    "lastname": lastname,
    "date": date?.toIso8601String(),
    "content": content,
  };
}

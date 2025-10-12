import 'dart:convert';

import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/mosque.dart';
import 'package:intl/intl.dart';

List<Salat> salatFromJson(jsondata) => List<Salat>.from(jsondata.map((x) => Salat.fromJson(x)));
String salatToJson(List<Salat> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Salat {
  int? id;
  String afiliation;
  String afiliationLabel;
  String firstname;
  String lastname;
  String content;
  String cimetary = "";
  String? dateDisplay;
  String? timeDisplay;
  DateTime? date;
  Bblocation? adress;
  Mosque? mosque;
  String mosqueName = "";
  bool canEdit;

  Salat({
    this.id,
    required this.afiliation,
    required this.afiliationLabel,
    required this.firstname,
    required this.lastname,
    required this.content,
    this.cimetary = "",
    this.mosqueName = "",
    this.date,
    required this.dateDisplay,
    required this.timeDisplay,
    this.adress,
    this.mosque,
    required this.canEdit,
  });

  factory Salat.fromJson(Map<String, dynamic> json) => Salat(
    id: json["id"],
    afiliation: json["afiliation"],
    afiliationLabel: json["afiliationLabel"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    cimetary: json["cimetary"] == null ? "" : json["cimetary"],
    dateDisplay:  json["date"] != null ? DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(DateTime.parse(json["date"])) : "",
    timeDisplay:  json["timeDisplay"] != null ? json["timeDisplay"] : "",
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    adress: json["adress"] != null ? Bblocation.fromJson(json["adress"]) : null,
    content: json["content"],
    mosque: json["mosque"] != null ? Mosque.fromJson(json["mosque"]) : null,
    mosqueName: json["mosqueName"] ?? "",
    canEdit: json["canEdit"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "afiliation": afiliation,
    "firstname": firstname,
    "lastname": lastname,
    "date": date?.toIso8601String(),
    "adress": adress?.toJson(),
    "mosque": mosque?.toJson(),
    "content": content,
    "cimetary": cimetary,
    "mosqueName": mosqueName,
  };
}

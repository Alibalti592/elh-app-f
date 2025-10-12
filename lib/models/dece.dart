// To parse this JSON data, do
//
//     final dece = deceFromJson(jsonString);

import 'dart:convert';

import 'package:elh/models/BBLocation.dart';
import 'package:intl/intl.dart';

List<Dece> deceFromJson(jsondata) => List<Dece>.from(jsondata.map((x) => Dece.fromJson(x)));
String deceToJson(List<Dece> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Dece {
  int? id;
  String afiliation;
  String afiliationLabel;
  String lieu;
  String lieuLabel;
  String firstname;
  String lastname;
  String phone = "";
  bool   notifPf = false;
  bool   notifyMosque = false;
  String? dateDisplay;
  DateTime? date;
  Bblocation? adress;

  Dece({
    this.id,
    required this.afiliation,
    required this.afiliationLabel,
    required this.lieu,
    required this.lieuLabel,
    required this.firstname,
    required this.lastname,
    required this.notifPf,
    required this.notifyMosque,
    this.date,
    required this.dateDisplay,
    this.adress,
    this.phone = "",
  });

  factory Dece.fromJson(Map<String, dynamic> json) => Dece(
    id: json["id"],
    afiliation: json["afiliation"],
    afiliationLabel: json["afiliationLabel"],
    lieu: json["lieu"],
    lieuLabel: json["lieuLabel"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    phone: json["phone"],
    notifPf: json["notifPf"] == null ? false : json["notifPf"],
    notifyMosque: json["notifyMosque"] == null ? false : json["notifyMosque"],
    dateDisplay:  json["date"] != null ? DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(DateTime.parse(json["date"])) : "",
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    adress: Bblocation.fromJson(json["adress"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "afiliation": afiliation,
    "lieu": lieu,
    "firstname": firstname,
    "lastname": lastname,
    "notifPf": notifPf,
    "phone": phone,
    "notifyMosque": notifyMosque,
    "date": date?.toIso8601String(),
    "adress": adress?.toJson(),
  };
}

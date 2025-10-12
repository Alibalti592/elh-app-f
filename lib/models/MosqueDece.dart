import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/models/dece.dart';
import 'package:elh/models/pompe.dart';

List<DeceMosque> deceMosquesFromJson(jsonData) => List<DeceMosque>.from(jsonData.map((x) => DeceMosque.fromJson(x)));

class DeceMosque {
  int? id;
  Dece dece;
  String dateString;
  bool showOnPage;

  DeceMosque({
    this.id,
    required this.dece,
    required this.dateString,
    required this.showOnPage,
  });

  factory DeceMosque.fromJson(Map<String, dynamic> json) => DeceMosque(
    id: json["id"],
    dateString: json["date"] == null ? "" : json["date"],
    showOnPage: json["showOnPage"] == null ? false : json["showOnPage"],
    dece: Dece.fromJson(json["dece"]),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}
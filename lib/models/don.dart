import 'dart:convert';
import 'package:elh/models/BBLocation.dart';

List<Don> donsFromJson(jsondata) => List<Don>.from(jsondata.map((x) => Don.fromJson(x)));
String donsToJson(List<Don> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Don {
  int id;
  String name;
  String description;
  String? link;
  String? logo;
  bool isExpanded;
  bool isInApp;

  Don({
    required this.id,
    required this.name,
    required this.description,
    required this.link,
    required this.logo,
    this.isExpanded = false,
    this.isInApp = false,
  });

  factory Don.fromJson(Map<String, dynamic> json) => Don(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    link: json["link"],
    logo: json["logo"],
    isExpanded: false, //UI
    isInApp: json["isInApp"] == null ? false : json["isInApp"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
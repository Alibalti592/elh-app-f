import 'dart:convert';
import 'package:elh/models/BBLocation.dart';

List<Imam> imamsFromJson(jsondata) => List<Imam>.from(jsondata.map((x) => Imam.fromJson(x)));
String imamsToJson(List<Imam> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Imam {
  int id;
  String name;
  String description;
  bool online;
  Bblocation location;
  bool isExpanded;
  int distance;
  bool isInApp;

  Imam({
    required this.id,
    required this.name,
    required this.description,
    required this.online,
    required this.location,
    this.isExpanded = false,
    required this.distance,
    this.isInApp = false,
  });

  factory Imam.fromJson(Map<String, dynamic> json) => Imam(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    online: json["online"],
    location: Bblocation.fromJson(json["location"]),
    isExpanded: false, //UI
    distance: json["distance"].toInt(),
    isInApp: json["isInApp"] == null ? false : json["isInApp"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "online": online,
    "location": location.toJson(),
  };
}
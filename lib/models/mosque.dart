import 'dart:convert';
import 'package:elh/models/BBLocation.dart';

List<Mosque> mosqueFromJson(String str) => List<Mosque>.from(json.decode(str).map((x) => Mosque.fromJson(x)));
String mosqueToJson(List<Mosque> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Mosque {
  int id;
  String name;
  String description;
  bool online;
  Bblocation location;
  bool isExpanded;
  int distance;
  bool isFavorite;

  Mosque({
    required this.id,
    required this.name,
    required this.description,
    required this.online,
    required this.location,
    required this.isExpanded,
    required this.distance,
    required this.isFavorite,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    online: json["online"],
    location: Bblocation.fromJson(json["location"]),
    isExpanded: false, //UI
    distance: json["distance"].toInt(),
    isFavorite: json["isFavorite"] == null ? false : json["isFavorite"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "online": online,
    "location": location.toJson(),
  };
}
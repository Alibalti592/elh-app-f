import 'dart:convert';

import 'package:elh/models/BBLocation.dart';
import 'package:intl/intl.dart';
List<Maraude> maraudeFromJson(String str) => List<Maraude>.from(json.decode(str).map((x) => Maraude.fromJson(x)));
String maraudeToJson(List<Maraude> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Maraude {
  int? id;
  Bblocation? location;
  String? dateDisplay;
  DateTime? date;
  String description;
  bool online;
  bool validated;
  bool isExpanded;
  int distance;
  String? timeDisplay;

  Maraude({
    this.id,
    this.location,
    required this.date,
    required this.description,
    required this.online,
    required this.validated,
    required this.dateDisplay,
    required this.isExpanded,
    required this.distance,
    required this.timeDisplay
  });

  factory Maraude.fromJson(Map<String, dynamic> json) => Maraude(
    id: json["id"],
    location: Bblocation.fromJson(json["location"]),
    description: json["description"] == null ? "" : json["description"],
    online: json["online"],
    validated: json["validated"],
    dateDisplay:  json["date"] != null ? DateFormat("EEEE dd MMMM yyyy", 'fr_FR').format(DateTime.parse(json["date"])) : "",
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    isExpanded: false,
    distance: json["distance"].toInt(),
    timeDisplay:  json["timeDisplay"] != null ? json["timeDisplay"] : "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "location": location?.toJson(),
    "date": date,
    "description": description,
    "online": online,
    "date": date?.toIso8601String(),
  };
}
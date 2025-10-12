import 'package:elh/models/BBLocation.dart';
import 'dart:convert';

Praytime praytimeFromJson(jsonDatas) => Praytime.fromJson(jsonDatas);

String praytimeToJson(Praytime data) => json.encode(data.toJson());

class Praytime {
  Bblocation location;
  String date;
  String dateMuslim;
  List<Priere> prieres;

  Praytime({
    required this.location,
    required this.date,
    required this.dateMuslim,
    required this.prieres,
  });

  factory Praytime.fromJson(Map<String, dynamic> json) => Praytime(
    location: Bblocation.fromJson(json["location"]),
    date: json["date"],
    dateMuslim: json["dateMuslim"],
    prieres: List<Priere>.from(json["prieres"].map((x) => Priere.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "location": location.toJson(),
    "date": date,
    "dateMuslim": dateMuslim,
    "prieres": List<dynamic>.from(prieres.map((x) => x.toJson())),
  };
}

class Priere {
  String time;
  int timestamp;
  String label;
  String key;
  bool isNotified = false;

  Priere({
    required this.time,
    required this.timestamp,
    required this.label,
    required this.key,
    required this.isNotified,
  });

  factory Priere.fromJson(Map<String, dynamic> json) => Priere(
    time: json["time"],
    label: json["label"],
    key: json["key"],
    isNotified: json["isNotified"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "timestamp": timestamp,
    "label": label,
    "key": key,
    "isNotified": isNotified,
  };
}

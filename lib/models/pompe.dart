import 'dart:convert';
import 'package:elh/models/BBLocation.dart';

List<Pompe> pompeFromJson(String str) =>
    List<Pompe>.from(json.decode(str).map((x) => Pompe.fromJson(x)));
String pompeToJson(List<Pompe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Pompe {
  int? id;
  String name;
  String description;
  String phone;
  String phonePrefix;
  String phoneUrgence;
  String phoneUrgencePrefix;
  String namePro;
  String emailPro;
  bool online;
  bool validated;
  Bblocation location;
  bool isExpanded;
  int distance;

  Pompe({
    this.id,
    required this.name,
    required this.description,
    required this.online,
    required this.validated,
    required this.location,
    required this.isExpanded,
    required this.distance,
    this.namePro = '',
    this.phone = '',
    this.phonePrefix = '+33',
    this.phoneUrgence = '',
    this.phoneUrgencePrefix = '+33',
    this.emailPro = '',
  });

  factory Pompe.fromJson(Map<String, dynamic> json) => Pompe(
      id: json["id"],
      name: json["name"] == null ? "" : json["name"],
      description: json["description"] == null ? "" : json["description"],
      phone: json["phone"],
      phonePrefix: json["phonePrefix"],
      phoneUrgence: json["phoneUrgence"],
      phoneUrgencePrefix: json["phoneUrgencePrefix"],
      online: json["online"],
      validated: json["validated"],
      namePro: json["namePro"] == null ? "" : json["namePro"],
      emailPro: json["emailPro"] == null ? "" : json["emailPro"],
      location: Bblocation.fromJson(json["location"]),
      isExpanded: false, //UI
      distance: json["distance"].toInt());

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "online": online,
        "location": location.toJson(),
        "phone": phone,
        "phonePrefix": phonePrefix,
        "phoneUrgence": phoneUrgence,
        "phoneUrgencePrefix": phoneUrgencePrefix,
        "emailPro": emailPro,
        "namePro": namePro,
      };
}

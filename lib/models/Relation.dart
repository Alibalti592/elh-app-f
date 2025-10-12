import 'dart:convert';
import 'package:elh/models/userInfos.dart';

List<Relation> relationFromJson(json) => List<Relation>.from(json.map((x) => Relation.fromJson(x)));
String relationToJson(List<Relation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Relation {
  int? id;
  String status;
  UserInfos user;
  bool shareTestament = false;
  bool active = false; //for sharewith for exemple

  Relation({
    this.id,
    required this.status,
    required this.user,
    required this.shareTestament,
    required this.active,
  });

  factory Relation.fromJson(Map<String, dynamic> json) => Relation(
    id: json["id"],
    status: json["status"],
    user: UserInfos.fromJson(json["user"]),
    shareTestament: json["shareTestament"] ?? false,
    active: json["active"] ?? false
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "user": user.toJson(),
    "shareTestament": shareTestament,
    "active": active,
  };
}
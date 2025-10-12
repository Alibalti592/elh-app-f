import 'package:elh/models/ChatMessage.dart';

class Thread {
  Thread({
    this.id,
    required this.name,
    required this.groupName,
    required this.image,
    required this.type,
    required this.nbParticpants,
    required this.lastMessage,
    required this.lastUpdate,
    required this.hasMessage,
    required this.administrator,
  });

  int? id;
  String name;
  String groupName;
  String image;
  String type;
  String nbParticpants;
  String lastMessage;
  String lastUpdate;
  bool hasMessage;
  bool administrator;

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
    id: json["id"],
    name: json["name"],
    groupName:  json["groupName"] == null ? "" : json["groupName"],
    image: json["image"] == null ? "" : json["image"],
    type: json["type"],
    nbParticpants: json["nbParticpants"],
    lastMessage: json["lastMessage"],
    lastUpdate: json["lastUpdate"],
    hasMessage: json["hasMessage"],
    administrator: json["administrator"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "groupName": groupName,
    "image": image,
    "type": type,
    "nbParticpants": nbParticpants,
    "lastMessage": lastMessage,
    "lastUpdate": lastUpdate,
    "hasMessage": hasMessage,
    "administrator": administrator,
  };
}

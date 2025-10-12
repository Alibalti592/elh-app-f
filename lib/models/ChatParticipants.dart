import 'dart:convert';
List<Participant> participantFromJson(jsonDatas) => List<Participant>.from(jsonDatas.map((x) => Participant.fromJson(x)));
String participantToJson(List<Participant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Participant {

  Participant({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  String id;
  String name;
  String imageUrl;

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"].toString(),
    name: json["name"],
    imageUrl: json["imageUrl"] == null ? "" : json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
  };
}
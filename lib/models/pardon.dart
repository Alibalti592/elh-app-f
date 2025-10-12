import 'dart:convert';
//final pardon = pardonFromJson(jsonString);
List<Pardon> pardonFromJson(jsondata) => List<Pardon>.from(jsondata.map((x) => Pardon.fromJson(x)));
String pardonToJson(List<Pardon> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Pardon {
  int? id;
  String content;
  String firstname;
  String lastname;
  bool isExpanded = false;
  bool canEdit = false;

  Pardon({
    this.id,
    required this.content,
    required this.firstname,
    required this.lastname,
    this.isExpanded = false,
    this.canEdit = false,
  });

  factory Pardon.fromJson(Map<String, dynamic> json) => Pardon(
    id: json["id"],
    content: json["content"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    canEdit: json["canEdit"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "content": content,
  };
}

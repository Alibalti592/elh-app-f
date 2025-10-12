import 'dart:convert';

ContactList contactListFromJson(String str) => ContactList.fromJson(json.decode(str));

String contactListToJson(ContactList data) => json.encode(data.toJson());

class ContactList {
  ContactList({
    required this.data,
  });

  List<Contact> data;

  factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
    data: List<Contact>.from(json["data"].map((x) => Contact.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Contact {
  Contact({
    required this.id,
    required this.type,
    required this.name,
    required this.photo,
    required this.canContact,
    required this.hasMessage,
  });

  int id;
  String type;
  String name;
  String photo;
  bool canContact;
  bool hasMessage;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json["id"],
    type: json["type"],
    name: json["name"],
    photo: json["photo"],
    canContact: json["canContact"],
    hasMessage: json["hasMessage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "photo": photo,
    "canContact": canContact,
    "hasMessage": hasMessage
  };
}
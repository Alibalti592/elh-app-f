import 'dart:convert';

List<ChatMessage> chatMessagesFromJson(jsonData) => List<ChatMessage>.from(jsonData.map((x) => ChatMessage.fromJson(x)));
String messageToJson(List<ChatMessage> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.type,
    required this.author,
    required this.edited,
    required this.deleted,
    required this.showAuthor,
    this.message,
    this.fileMessage,
  });

  String id;
  String type;
  String author;
  bool edited;
  bool deleted;
  bool showAuthor;
  Message? message;
  FileMessage? fileMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      ChatMessage(
        id: json["id"],
        type: json["type"],
        author: json["author"].toString(),
        showAuthor: json["showAuthor"],
        edited: json["edited"],
        deleted: json["deleted"],
        message: Message.fromJson(json["data"]),
        fileMessage: json["data"]['file'] == null ? null : FileMessage.fromJson(json["data"]['file']),
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "type": type,
        "author": author,
        "message": message?.toJson(),
      };
}

class Message {
  Message({
    required this.text,
    required this.meta,
  });

  String text;
  String meta;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    text: json["text"],
    meta: json["meta"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "meta": meta,
  };
}


class FileMessage {
  String link;
  String type;
  String label;

  FileMessage({
    required this.link,
    required this.type,
    required this.label,
  });

  factory FileMessage.fromJson(Map<String, dynamic> json) => FileMessage(
    link: json["link"],
    type: json["type"],
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "link": link,
    "type": type,
    "label": label,
  };
}
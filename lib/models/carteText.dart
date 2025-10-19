import 'dart:convert';

List<CarteText> carteTextFromJson(jsondata) =>
    List<CarteText>.from(jsondata.map((x) => CarteText.fromJson(x)));
String carteTextToJson(List<CarteText> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarteText {
  String type;
  String content;
  bool forOther;

  CarteText({
    this.type = "",
    this.content = "",
    this.forOther = false,
  });

  factory CarteText.fromJson(Map<String, dynamic> json) => CarteText(
        type: json["type"], //death || malade
        content: json["content"],
        forOther: json["forOther"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "content": content,
      };
}

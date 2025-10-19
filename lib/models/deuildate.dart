import 'dart:convert';

List<DeuilDate> deuildatesFromJson(jsondata) =>
    List<DeuilDate>.from(jsondata.map((x) => DeuilDate.fromJson(x)));
String deuildatesToJson(List<DeuilDate> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeuilDate {
  int id;
  String date;

  DeuilDate({
    required this.id,
    required this.date,
  });

  factory DeuilDate.fromJson(Map<String, dynamic> json) => DeuilDate(
        id: json["id"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}

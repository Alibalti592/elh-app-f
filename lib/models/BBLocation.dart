// To parse this JSON data, do
//
//     final bbLocations = bbLocationsFromJson(jsonString);

import 'dart:convert';

BbLocations bbLocationsFromJson(String str) =>
    BbLocations.fromJson(json.decode(str));
String bbLocationsToJson(BbLocations data) => json.encode(data.toJson());

class BbLocations {
  List<Bblocation> bblocation;

  BbLocations({
    required this.bblocation,
  });

  factory BbLocations.fromJson(Map<String, dynamic> json) => BbLocations(
        bblocation: List<Bblocation>.from(
            json["bblocation"].map((x) => Bblocation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bblocation": List<dynamic>.from(bblocation.map((x) => x.toJson())),
      };
}

List<Bblocation> BbLocationsFromJson(jsonData) => (List<Bblocation>.from(
    jsonData.map((bblocation) => Bblocation.fromJson(bblocation))));

class Bblocation {
  String label;
  String displayLabel;
  double lat;
  double lng;
  String city;
  String postcode;
  String citycode;
  String region;
  String adress;
  String country = "France";

  Bblocation({
    required this.label,
    required this.displayLabel,
    required this.lat,
    required this.lng,
    required this.city,
    required this.postcode,
    required this.citycode,
    required this.region,
    required this.adress,
    this.country = "France",
  });

  //from url
  factory Bblocation.fromJsonPLaces(Map<String, dynamic> json) {
    //TODO : ATTETNION Call from api elh également ... séparer les 2 !!!
    String? city = json["address"]["village"];
    if (city == null) {
      city = json["address"]["city"];
    }
    if (city == null) {
      city = json["address"]["town"];
    }
    if (city == null) {
      city = "";
    }
    String number = json["address"]["house_number"] == null
        ? ""
        : "${json["address"]["house_number"]} ";
    String postcode = json["address"]["postcode"] == null
        ? ""
        : "${json["address"]["postcode"]} ";
    String road =
        json["address"]["road"] == null ? "" : "${json["address"]["road"]}, ";
    String country =
        json["address"]["country"] == null ? "" : json["address"]["country"];
    String adress = "$number$road$postcode$city";
    return Bblocation(
        label: adress,
        displayLabel: adress,
        lat: json["lat"] == null ? 0 : double.parse(json["lat"]),
        lng: json["lon"] == null ? 0 : double.parse(json["lon"]),
        city: city,
        postcode: json["address"]["postcode"] == null
            ? ""
            : json["address"]["postcode"],
        citycode: json["address"]["citycode"] == null
            ? ""
            : json["address"]["citycode"],
        region:
            json["address"]["region"] == null ? "" : json["address"]["region"],
        country: json["address"]["country"] == null
            ? ""
            : json["address"]["country"],
        adress: adress);
  }

  factory Bblocation.fromJson(Map<String, dynamic> json) => Bblocation(
      label: json["label"] == null ? "" : json["label"],
      displayLabel: json["label"] == null
          ? ""
          : "${json["label"]} - ${json["context"] == null ? "" : json["context"]}",
      lat:
          json["lat"] == null ? 0 : json["lat"].toDouble(), //x et y not lat lng
      lng: json["lng"] == null ? 0 : json["lng"].toDouble(),
      city: json["city"] == null ? "" : json["city"],
      postcode: json["postcode"] == null ? "" : json["postcode"],
      citycode: json["citycode"] == null ? "" : json["citycode"],
      region: json["context"] == null ? "" : json["context"],
      adress: json["adress"] == null ? "" : json["adress"]);

  Map<String, dynamic> toJson() => {
        "label": label,
        "lat": lat,
        "lng": lng,
        "city": city,
        "postcode": postcode,
        "citycode": citycode,
        "region": region,
        "adress": adress,
        "country": country,
      };
}

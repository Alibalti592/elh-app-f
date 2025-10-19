import 'package:elh/models/dece.dart';
import 'package:elh/models/pompe.dart';

List<PompeDemand> pompeDemandsFromJson(jsonData) =>
    List<PompeDemand>.from(jsonData.map((x) => PompeDemand.fromJson(x)));

class PompeDemand {
  int? id;
  Pompe pompe;
  Dece dece;
  String dateString;
  String status;
  String statusLabel;

  PompeDemand(
      {this.id,
      required this.pompe,
      required this.dece,
      required this.dateString,
      required this.status,
      required this.statusLabel});

  factory PompeDemand.fromJson(Map<String, dynamic> json) => PompeDemand(
        id: json["id"],
        dateString: json["date"] == null ? "" : json["date"],
        status: json["status"] == null ? "" : json["status"],
        statusLabel: json["statusLabel"] == null ? "" : json["statusLabel"],
        pompe: Pompe.fromJson(json["pompe"]),
        dece: Dece.fromJson(json["dece"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}
